pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

import "root:/config"

// Bluetooth via bluetoothctl.
//
// Quickshell ships a native Quickshell.Bluetooth module, but this file
// deliberately shells out instead, for the same reason services/Network.qml
// uses nmcli: a missing or renamed QML module is an *import* error, which
// takes down the entire shell at load time rather than just disabling one
// icon. bluetoothctl's non-interactive subcommands have been stable across
// the whole BlueZ 5 series and degrade gracefully — if the binary isn't
// there, the module simply reports itself unavailable and the bar hides it.
//
// One poll runs one shell pipeline: adapter state, then a line per known
// device with its paired/connected/battery state folded in. Doing it in a
// single process keeps this to one spawn per cycle instead of one per
// device.
Singleton {
    id: root

    property bool available: false      // bluetoothctl present and an adapter exists
    property bool powered: false
    property string adapter: ""
    property bool scanning: false
    property bool busy: false

    // Each entry: { mac, name, paired, connected, kind, battery }
    // battery is -1 when the device doesn't report one.
    property var devices: []

    readonly property var connectedDevices: devices.filter(d => d.connected)
    readonly property bool anyConnected: connectedDevices.length > 0

    // Paired devices first, then connected ones on top of that — the order
    // macOS uses for "My Devices", with everything merely in range below.
    readonly property var knownDevices: devices.filter(d => d.paired)
    readonly property var nearbyDevices: devices.filter(d => !d.paired)

    // ── Poll rate ───────────────────────────────────────────────────
    property int monitorCount: 0
    readonly property bool monitoring: monitorCount > 0

    function addMonitor(): void {
        monitorCount++;
    }

    function removeMonitor(): void {
        if (monitorCount > 0)
            monitorCount--;
    }

    // ── The poll ────────────────────────────────────────────────────
    // Emits one ADAPTER line then one DEV line per device, pipe-separated.
    // Fields are read out of `bluetoothctl info` rather than parsed from
    // `devices Connected`/`devices Paired`, because a device can be paired,
    // connected, both or neither and one info call answers all of it at once.
    readonly property string pollScript: `
        command -v bluetoothctl >/dev/null 2>&1 || { echo "UNAVAILABLE"; exit 0; }
        show=$(bluetoothctl show 2>/dev/null)
        case "$show" in
            "") echo "UNAVAILABLE"; exit 0 ;;
            *"No default controller"*) echo "UNAVAILABLE"; exit 0 ;;
        esac
        printf 'ADAPTER|%s|%s\\n' \
            "$(printf '%s\\n' "$show" | awk '/^Controller/{print $2; exit}')" \
            "$(printf '%s\\n' "$show" | awk '/Powered:/{print $2; exit}')"
        bluetoothctl devices 2>/dev/null | while read -r _ mac name; do
            [ -n "$mac" ] || continue
            info=$(bluetoothctl info "$mac" 2>/dev/null)
            printf 'DEV|%s|%s|%s|%s|%s|%s\\n' \
                "$mac" \
                "$name" \
                "$(printf '%s\\n' "$info" | awk '/Paired:/{print $2; exit}')" \
                "$(printf '%s\\n' "$info" | awk '/Connected:/{print $2; exit}')" \
                "$(printf '%s\\n' "$info" | awk '/Icon:/{print $2; exit}')" \
                "$(printf '%s\\n' "$info" | awk '/Battery Percentage:/{gsub(/[()]/,"",$4); print $4; exit}')"
        done
    `

    Process {
        id: pollProc
        command: ["sh", "-c", root.pollScript]
        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text;
                if (text.indexOf("UNAVAILABLE") !== -1) {
                    root.available = false;
                    root.powered = false;
                    root.devices = [];
                    return;
                }

                const list = [];
                for (const raw of text.split("\n")) {
                    const line = raw.trim();
                    if (!line)
                        continue;
                    const f = line.split("|");

                    if (f[0] === "ADAPTER") {
                        root.available = true;
                        root.adapter = f[1] ?? "";
                        root.powered = (f[2] ?? "").trim() === "yes";
                        continue;
                    }

                    if (f[0] !== "DEV")
                        continue;

                    const battery = parseInt(f[6] ?? "", 10);
                    list.push({
                        mac: f[1] ?? "",
                        name: (f[2] ?? "").trim() || (f[1] ?? ""),
                        paired: (f[3] ?? "").trim() === "yes",
                        connected: (f[4] ?? "").trim() === "yes",
                        kind: (f[5] ?? "").trim(),
                        battery: isNaN(battery) ? -1 : battery
                    });
                }

                // Connected first, then paired, then alphabetical — the
                // thing you're most likely to want to tap is nearest the top.
                list.sort((a, b) =>
                    (b.connected - a.connected)
                    || (b.paired - a.paired)
                    || a.name.localeCompare(b.name));

                root.devices = list;
            }
        }
    }

    // ── Actions ─────────────────────────────────────────────────────
    Process {
        id: powerProc
        onExited: root.refresh()
    }

    Process {
        id: actionProc
        onExited: {
            root.busy = false;
            root.refresh();
        }
    }

    Process {
        id: scanProc
        onExited: {
            root.scanning = false;
            root.refresh();
        }
    }

    Timer {
        // Idle polling is slow but not off: the bar icon still needs to know
        // whether the adapter is powered and whether anything is connected.
        interval: root.monitoring ? 4000 : 20000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    function refresh(): void {
        pollProc.running = true;
    }

    function togglePower(): void {
        // rfkill first: a soft-blocked adapter refuses `power on` outright,
        // and a rfkill block is the usual reason Bluetooth "won't turn on".
        powerProc.command = powered
            ? ["bluetoothctl", "power", "off"]
            : ["sh", "-c", "rfkill unblock bluetooth 2>/dev/null; bluetoothctl power on"];
        powerProc.running = true;
    }

    function scan(): void {
        if (scanning)
            return;
        scanning = true;
        scanProc.command = ["bluetoothctl", "--timeout",
                            String(Settings.bluetoothScanSeconds), "scan", "on"];
        scanProc.running = true;
    }

    function connectDevice(mac: string, paired: bool): void {
        busy = true;
        // An unpaired device has to be paired and trusted before it will
        // connect. Trusting is what lets it reconnect on its own later
        // instead of needing this dance every time.
        actionProc.command = paired
            ? ["bluetoothctl", "connect", mac]
            : ["sh", "-c",
               "bluetoothctl pair " + mac
               + " && bluetoothctl trust " + mac
               + " && bluetoothctl connect " + mac];
        actionProc.running = true;
    }

    function disconnectDevice(mac: string): void {
        busy = true;
        actionProc.command = ["bluetoothctl", "disconnect", mac];
        actionProc.running = true;
    }

    function forgetDevice(mac: string): void {
        busy = true;
        actionProc.command = ["bluetoothctl", "remove", mac];
        actionProc.running = true;
    }
}
