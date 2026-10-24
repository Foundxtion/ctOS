# Included by writeShellApplication, which supplies bash and strict mode.
state_dir="${STATE_DIRECTORY:-/var/lib/ctos-k8s-maintenance}"
pending="$state_dir/pending.json"
lease_name=ctos-node-maintenance
boot_id=$(cat /proc/sys/kernel/random/boot_id)
mkdir -p "$state_dir"

# Also serialize local manual starts of the two units.
exec 9>"$state_dir/lock"
flock -n 9 || exit 1

kube() {
    # Use k3s's bundled kubectl so the client matches the cluster version.
    k3s kubectl --request-timeout=30s "$@"
}

lease() {
    kube -n kube-system get lease "$lease_name" --ignore-not-found -o json
}

release_lease() {
    local current
    current=$(lease) || return 1
    if [[ -z "$current" ]]; then
        echo "Maintenance lease missing; leaving state for operator recovery." >&2
        return 1
    fi
    [[ $(jq -r '.spec.holderIdentity' <<<"$current") == "$holder" ]] || return 1
    # Preconditions make this atomic: an operator replacing/updating the Lease
    # between our read and delete must not have their new lock removed.
    jq -ce '{apiVersion: "v1", kind: "DeleteOptions",
        preconditions: {uid: .metadata.uid, resourceVersion: .metadata.resourceVersion}}' <<<"$current" \
        | kube delete --raw="/apis/coordination.k8s.io/v1/namespaces/kube-system/leases/$lease_name" -f -
}

healthy_cluster() {
    local nodes
    nodes=$(kube get nodes -o json) || return 1
    # Require an HA control plane and every node to be healthy/schedulable.
    # A node Ready check alone cannot prove etcd health, but refusing existing
    # outages and holding the cluster lock avoids overlapping ctOS maintenance.
    jq -e --arg node "$NODE_NAME" '
        def ready: any(.status.conditions[]?; .type == "Ready" and .status == "True");
        [.items[] | select(.metadata.labels | has("node-role.kubernetes.io/control-plane"))] as $servers |
        ($servers | length) >= 3 and
        any(.items[]; .metadata.name == $node) and
        all(.items[]; ready and (.spec.unschedulable != true))
    ' <<<"$nodes" >/dev/null
}

if [[ "${1:-}" == resume ]]; then
    [[ -f "$pending" ]] || exit 0
    NODE_NAME=$(jq -er '.node' "$pending")
    holder=$(jq -er '.holder' "$pending")
    previous_boot=$(jq -er '.boot' "$pending")
    phase=$(jq -er '.phase' "$pending")
    drain_started=$(jq -er '.drainStarted | if type == "boolean" then tostring else error("Invalid drain state") end' "$pending")
    if [[ "$drain_started" == true && "$previous_boot" == "$boot_id" && "$phase" != rollback ]]; then
        echo "Waiting for a new boot before returning $NODE_NAME to service." >&2
        exit 1
    fi
    current=$(lease)
    [[ -n "$current" && $(jq -r '.spec.holderIdentity' <<<"$current") == "$holder" ]] || {
        echo "Maintenance lease does not match local state; operator recovery required." >&2
        exit 1
    }
    if [[ "$drain_started" == true ]]; then
        # Avoid accepting a stale Ready condition from before the reboot.
        kube wait "node/$NODE_NAME" "--for=jsonpath={.status.nodeInfo.bootID}=$boot_id" --timeout="$READY_TIMEOUT"
        kube wait "node/$NODE_NAME" --for=condition=Ready --timeout="$READY_TIMEOUT"
        kube uncordon "$NODE_NAME"
    fi
    release_lease
    rm -- "$pending"
    if [[ "$drain_started" == true ]]; then
        echo "$NODE_NAME is Ready and schedulable again. Existing pods elsewhere are not moved back automatically."
    else
        echo "Released the maintenance lease; no drain was started."
    fi
    exit 0
fi

[[ "${1:-}" == reboot ]] || { echo "Expected reboot or resume" >&2; exit 2; }
[[ ! -f "$pending" ]] || { echo "Previous maintenance is still pending." >&2; exit 1; }
healthy_cluster || { echo "Skipping reboot: require at least three control-plane nodes and all nodes Ready/schedulable." >&2; exit 1; }

holder="$boot_id"
drain_started=false
write_pending() {
    jq -n --arg node "$NODE_NAME" --arg holder "$holder" --arg boot "$boot_id" --arg phase "$1" \
        --argjson drainStarted "$drain_started" \
        '{node: $node, holder: $holder, boot: $boot, phase: $phase, drainStarted: $drainStarted}' >"$pending.tmp"
    mv -- "$pending.tmp" "$pending"
    sync -f "$state_dir"
}

# Record ownership before the API call: a lost response must not lose the state
# needed to recover a successfully acquired lock. Never steal a stale lock.
write_pending draining
if ! jq -n --arg name "$lease_name" --arg holder "$holder" --arg node "$NODE_NAME" \
    '{apiVersion: "coordination.k8s.io/v1", kind: "Lease",
      metadata: {name: $name, namespace: "kube-system", annotations: {"ctos.foundxtion.com/node": $node}},
      spec: {holderIdentity: $holder}}' \
    | kube create -f -; then
    current=$(lease)
    if [[ -z "$current" || $(jq -r '.spec.holderIdentity' <<<"$current") != "$holder" ]]; then
        rm -- "$pending"
    else
        release_lease
        rm -- "$pending"
    fi
    echo "Maintenance lock unavailable; no drain or reboot was attempted." >&2
    exit 1
fi

rollback() {
    local status=$?
    trap - EXIT
    # Keep both the lock and recovery state when the API is unavailable.
    write_pending rollback
    if { [[ "$drain_started" == false ]] || kube uncordon "$NODE_NAME"; } && release_lease; then
        rm -- "$pending"
    else
        echo "Rollback incomplete; retaining the cluster lock and recovery state." >&2
        systemctl start --no-block ctos-k8s-resume.service || true
    fi
    exit "$status"
}
trap rollback EXIT
trap 'exit 1' TERM INT

# Recheck after acquiring the lock; another maintenance may have just finished.
healthy_cluster
drain_flags=(--ignore-daemonsets --timeout="$DRAIN_TIMEOUT")
if [[ "$DELETE_EMPTYDIR_DATA" == true ]]; then
    drain_flags+=(--delete-emptydir-data)
fi
# No --force or --disable-eviction: unmanaged pods/PDBs block maintenance.
drain_started=true
write_pending draining
kube drain "$NODE_NAME" "${drain_flags[@]}"
write_pending rebooting
systemctl reboot --no-block
# Recovery owns the lock until the next boot has become Ready and uncordoned.
trap - EXIT TERM INT
