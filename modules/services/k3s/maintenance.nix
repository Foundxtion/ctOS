{ config, lib, pkgs, ... }:
let
  cfg = config.fndx.services.k3s;
  reboot = cfg.reboot;
  maintenance = pkgs.writeShellApplication {
    name = "ctos-k8s-maintenance";
    runtimeInputs = [ pkgs.coreutils pkgs.jq pkgs.util-linux config.services.k3s.package pkgs.systemd ];
    text = builtins.readFile ./maintenance.sh;
  };
  common = {
    after = [ "network-online.target" "k3s.service" ];
    wants = [ "network-online.target" ];
    requires = [ "k3s.service" ];
    environment = {
      KUBECONFIG = reboot.kubeconfig;
      NODE_NAME = reboot.nodeName;
      DRAIN_TIMEOUT = reboot.drainTimeout;
      READY_TIMEOUT = reboot.readyTimeout;
      DELETE_EMPTYDIR_DATA = lib.boolToString reboot.deleteEmptyDirData;
    };
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "ctos-k8s-maintenance";
      StateDirectoryMode = "0700";
      UMask = "0077";
      TimeoutStartSec = "infinity"; # kubectl bounds each operation itself
    };
  };
in
{
  options.fndx.services.k3s.reboot = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable scheduled, serialized drain/reboot/uncordon maintenance for an HA k3s cluster.";
    };
    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "Sun *-*-* 04:00:00";
      example = "Mon *-*-* 03:00:00";
      description = "Systemd calendar expression in the node's local timezone. Stagger it across nodes.";
    };
    randomizedDelaySec = lib.mkOption {
      type = lib.types.str;
      default = "0";
      example = "30m";
      description = "Optional random delay after the scheduled maintenance time.";
    };
    nodeName = lib.mkOption {
      type = lib.types.str;
      default = lib.toLower config.networking.hostName;
      description = "Kubernetes node name, matching k3s --node-name when customized.";
    };
    kubeconfig = lib.mkOption {
      type = lib.types.str;
      default = "/etc/rancher/k3s/k3s.yaml";
      description = "Runtime kubeconfig with node, eviction and kube-system Lease permissions. Keep it root-readable only.";
    };
    drainTimeout = lib.mkOption {
      type = lib.types.str;
      default = "15m";
      description = "Maximum time to wait for a drain respecting PodDisruptionBudgets.";
    };
    readyTimeout = lib.mkOption {
      type = lib.types.str;
      default = "15m";
      description = "Maximum time per attempt to wait for node readiness after reboot.";
    };
    deleteEmptyDirData = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Explicitly allow drain to discard emptyDir data. Otherwise these pods block the reboot.";
    };
  };

  config = lib.mkIf (cfg.enable && reboot.enable) {
    systemd.timers.ctos-k8s-reboot = {
      description = "Schedule safe Kubernetes node maintenance";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = reboot.onCalendar;
        RandomizedDelaySec = reboot.randomizedDelaySec;
        Persistent = false; # Never catch up a missed reboot immediately at boot.
        Unit = "ctos-k8s-reboot.service";
      };
    };
    systemd.services.ctos-k8s-reboot = lib.recursiveUpdate common {
      description = "Drain the Kubernetes node and reboot only after a successful drain";
      serviceConfig.ExecStart = "${maintenance}/bin/ctos-k8s-maintenance reboot";
    };
    systemd.services.ctos-k8s-resume = lib.recursiveUpdate common {
      description = "Return a node drained by ctOS to service after it becomes Ready";
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        ConditionPathExists = "/var/lib/ctos-k8s-maintenance/pending.json";
        StartLimitIntervalSec = 0;
      };
      serviceConfig = {
        ExecStart = "${maintenance}/bin/ctos-k8s-maintenance resume";
        Restart = "on-failure";
        RestartSec = "1m";
      };
    };
  };
}
