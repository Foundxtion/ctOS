pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

import "root:/config"

// Networking via nmcli, plus link statistics straight from the kernel.
//
// Quickshell does have a native Quickshell.Networking module, but it is very
// new (0.3.0) and its API is still settling. nmcli is stable, present on
// essentially every NetworkManager-based distro, and easy to reason about,
// so that's what this shell talks to. If you'd rather use the native module
// once it stabilizes, this is the only file you need to rewrite — every
// other module only talks to Network.* below.
//
// Three things get polled:
//   * nmcli radio          — is the Wi-Fi radio on
//   * nmcli device wifi    — the list of visible networks
//   * nmcli device show    — every interface's type, state, connection, IPs
// and one thing gets sampled rather than polled:
//   * /proc/net/dev        — cumulative byte counters, differenced over the
//                            sampling window to give a live throughput rate
//
// Everything speeds up while a panel is open (see addMonitor/removeMonitor)
// and idles back down when it closes, so an open Wi-Fi panel gets
// per-second numbers without the closed bar paying for them all day.
Singleton {
    id: root

    // ── Wi-Fi ───────────────────────────────────────────────────────
    property bool wifiEnabled: false
    property string connectedSsid: ""
    property int connectedSignal: 0
    property bool busy: false
    property bool scanning: false

    // List of { ssid, signal, secured, active } sorted strongest-first,
    // deduplicated by SSID (nmcli lists one row per BSSID).
    property var networks: []

    // ── Interfaces ──────────────────────────────────────────────────
    // Each entry: { device, type, state, connected, connection, ip4, ip6 }
    property var interfaces: []

    // The interface your traffic is actually going over. A connected wired
    // link wins over Wi-Fi — that is the order the kernel's own route
    // metrics use by default, and it matches what macOS reports as the
    // active service.
    readonly property var primary: {
        const conn = interfaces.filter(i => i.connected);
        return conn.find(i => i.type === "ethernet")
            ?? conn.find(i => i.type === "wifi")
            ?? conn[0]
            ?? null;
    }

    readonly property var ethernet: interfaces.find(i => i.type === "ethernet" && i.connected) ?? null
    readonly property var wifiDevice: interfaces.find(i => i.type === "wifi") ?? null
    readonly property bool onEthernet: ethernet !== null
    readonly property bool online: primary !== null

    // ── Throughput ──────────────────────────────────────────────────
    // Bytes per second on the primary interface, refreshed every sample.
    property var rates: ({})
    readonly property real rxRate: (primary && rates[primary.device]) ? rates[primary.device].rx : 0
    readonly property real txRate: (primary && rates[primary.device]) ? rates[primary.device].tx : 0

    property var lastSample: null
    property real lastSampleTime: 0

    // ── Poll rate ───────────────────────────────────────────────────
    // Panels call addMonitor() while they're on screen and removeMonitor()
    // when they close. A count rather than a flag, so two monitors each
    // showing the panel don't switch each other off.
    property int monitorCount: 0
    readonly property bool monitoring: monitorCount > 0

    function addMonitor(): void {
        monitorCount++;
    }

    function removeMonitor(): void {
        if (monitorCount > 0)
            monitorCount--;
    }

    // ── Helpers ─────────────────────────────────────────────────────

    // Split an nmcli -t line on unescaped colons. nmcli escapes any colon
    // that's part of a value (notably every colon in an IPv6 address) as
    // "\:", so a naive split shreds them.
    function splitTerse(line: string): var {
        return line
            .replace(/\\:/g, "\u0000")
            .split(":")
            .map(f => f.replace(/\u0000/g, ":"));
    }

    // 0..3, for the Wi-Fi glyph's arc count.
    function signalLevel(signal: int): int {
        if (signal >= 67)
            return 3;
        if (signal >= 40)
            return 2;
        if (signal >= 15)
            return 1;
        return 0;
    }

    function formatRate(bytesPerSecond: real): string {
        const bits = Settings.throughputInBits;
        const base = bits ? 1000 : 1024;
        const units = bits
            ? ["bit/s", "kbit/s", "Mbit/s", "Gbit/s"]
            : ["B/s", "KB/s", "MB/s", "GB/s"];

        let v = bits ? bytesPerSecond * 8 : bytesPerSecond;
        let i = 0;
        while (v >= base && i < units.length - 1) {
            v /= base;
            i++;
        }
        return v.toFixed(i === 0 ? 0 : 1) + " " + units[i];
    }

    // ── Wi-Fi radio state ───────────────────────────────────────────
    Process {
        id: radioProc
        command: ["nmcli", "-t", "-f", "WIFI", "radio"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = this.text.trim().toLowerCase().startsWith("enabled");
            }
        }
    }

    // ── Visible networks ────────────────────────────────────────────
    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = {};
                const list = [];
                let active = null;

                for (const raw of this.text.split("\n")) {
                    const line = raw.trim();
                    if (!line)
                        continue;
                    const parts = root.splitTerse(line);
                    const inUse = parts[0] === "*";
                    const ssid = parts[1] ?? "";
                    const signal = parseInt(parts[2] ?? "0", 10) || 0;
                    const security = parts[3] ?? "";
                    if (!ssid)
                        continue;

                    if (seen[ssid] !== undefined) {
                        // Keep the strongest BSSID's signal per SSID, and —
                        // importantly — if *this* row is the connected one,
                        // mark the already-stored entry active too. nmcli
                        // lists one row per BSSID, sorted by signal, so the
                        // in-use access point isn't necessarily the first
                        // row for its SSID; missing this update was why a
                        // connected network still looked "connectable".
                        const existing = list[seen[ssid]];
                        if (signal > existing.signal)
                            existing.signal = signal;
                        if (inUse) {
                            existing.active = true;
                            active = ssid;
                        }
                        continue;
                    }

                    seen[ssid] = list.length;
                    list.push({
                        ssid: ssid,
                        signal: signal,
                        secured: security !== "" && security !== "--",
                        active: inUse
                    });
                    if (inUse)
                        active = ssid;
                }

                list.sort((a, b) => (b.active - a.active) || (b.signal - a.signal));

                root.networks = list;
                root.connectedSsid = active ?? "";
                root.connectedSignal = active ? (list.find(n => n.ssid === active)?.signal ?? 0) : 0;
                root.scanning = false;
            }
        }
    }

    // ── Interfaces, states and addresses ────────────────────────────
    Process {
        id: devicesProc
        command: ["nmcli", "-t", "-f",
                  "GENERAL.DEVICE,GENERAL.TYPE,GENERAL.STATE,GENERAL.CONNECTION,IP4.ADDRESS,IP6.ADDRESS",
                  "device", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const list = [];
                let current = null;

                for (const raw of this.text.split("\n")) {
                    const line = raw.trim();
                    if (!line)
                        continue;

                    const parts = root.splitTerse(line);
                    const key = parts[0] ?? "";
                    // Re-join the remainder: an IPv6 address is itself full
                    // of colons, and splitTerse has already unescaped them.
                    const value = parts.slice(1).join(":");

                    if (key === "GENERAL.DEVICE") {
                        current = {
                            device: value,
                            type: "",
                            state: "",
                            connected: false,
                            connection: "",
                            ip4: "",
                            ip6: ""
                        };
                        if (Settings.ignoredInterfaces.indexOf(value) === -1)
                            list.push(current);
                        continue;
                    }

                    if (current === null)
                        continue;

                    if (key === "GENERAL.TYPE") {
                        current.type = value;
                    } else if (key === "GENERAL.STATE") {
                        // Terse form is "100 (connected)"; the numeric code
                        // is the stable part, the word is localised.
                        current.state = value;
                        current.connected = value.startsWith("100");
                    } else if (key === "GENERAL.CONNECTION") {
                        current.connection = (value === "--") ? "" : value;
                    } else if (key.startsWith("IP4.ADDRESS") && current.ip4 === "") {
                        current.ip4 = value;
                    } else if (key.startsWith("IP6.ADDRESS") && current.ip6 === "") {
                        // Link-local addresses are always present and never
                        // interesting; only keep a routable one.
                        if (!value.toLowerCase().startsWith("fe80"))
                            current.ip6 = value;
                    }
                }

                root.interfaces = list;
            }
        }
    }

    // ── Throughput sampling ─────────────────────────────────────────
    Process {
        id: statsProc
        command: ["cat", "/proc/net/dev"]
        stdout: StdioCollector {
            onStreamFinished: root.sampleStats(this.text)
        }
    }

    // /proc/net/dev holds cumulative counters, so a rate is the difference
    // between two samples over the real elapsed time between them — timed
    // by the clock rather than by the timer's nominal interval, so a
    // delayed or coalesced sample doesn't inflate the number.
    function sampleStats(text: string): void {
        const now = Date.now();
        const sample = {};
        const lines = text.split("\n");

        // First two lines are the two-row column header.
        for (let i = 2; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line)
                continue;
            const colon = line.indexOf(":");
            if (colon < 0)
                continue;

            const iface = line.substring(0, colon).trim();
            const f = line.substring(colon + 1).trim().split(/\s+/);
            if (f.length < 9)
                continue;

            // Receive columns are bytes, packets, errs, drop, fifo, frame,
            // compressed, multicast — so transmit bytes is the ninth field.
            sample[iface] = {
                rx: parseInt(f[0], 10) || 0,
                tx: parseInt(f[8], 10) || 0
            };
        }

        const elapsed = (now - lastSampleTime) / 1000;
        if (lastSample !== null && elapsed > 0.05) {
            const next = {};
            for (const iface in sample) {
                const prev = lastSample[iface];
                if (prev === undefined)
                    continue;
                // Counters reset when an interface goes down and back up;
                // clamp rather than reporting a huge negative spike.
                const drx = Math.max(0, sample[iface].rx - prev.rx);
                const dtx = Math.max(0, sample[iface].tx - prev.tx);
                next[iface] = { rx: drx / elapsed, tx: dtx / elapsed };
            }
            // A fresh object every time: reassigning the same one in place
            // wouldn't fire a change notification and the readout would
            // freeze at its first value.
            rates = next;
        }

        lastSample = sample;
        lastSampleTime = now;
    }

    // ── Actions ─────────────────────────────────────────────────────
    Process {
        id: rescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onExited: listProc.running = true
    }

    Process {
        id: toggleProc
        property bool nextState: true
        command: ["nmcli", "radio", "wifi", nextState ? "on" : "off"]
        onExited: root.refreshStatus()
    }

    Process {
        id: connectProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.busy = false;
                root.refreshStatus();
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0) {
                    root.busy = false;
                    console.warn("Network: connect failed:", this.text.trim());
                }
            }
        }
    }

    Process {
        id: forgetProc
        onExited: root.refreshStatus()
    }

    // ── Timers ──────────────────────────────────────────────────────
    Timer {
        // Keeps the bar icon accurate even when every dropdown is closed,
        // and tightens up while one is open.
        interval: root.monitoring ? Settings.wifiScanInterval : 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshStatus()
    }

    Timer {
        // Kept running even when idle so the throughput figures are already
        // warm the instant the panel opens, rather than reading zero until
        // a second sample lands.
        interval: root.monitoring ? Settings.throughputInterval : 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statsProc.running = true
    }

    // ── Public API ──────────────────────────────────────────────────
    function refreshStatus(): void {
        radioProc.running = true;
        listProc.running = true;
        devicesProc.running = true;
    }

    function scan(): void {
        scanning = true;
        rescanProc.running = true;
    }

    function toggleWifi(): void {
        toggleProc.nextState = !wifiEnabled;
        toggleProc.running = true;
    }

    function connectTo(ssid: string, password: string): void {
        busy = true;
        const cmd = ["nmcli", "device", "wifi", "connect", ssid];
        if (password && password.length > 0)
            cmd.push("password", password);
        connectProc.command = cmd;
        connectProc.running = true;
    }

    // Drops the connection on a device without deleting the saved profile.
    function disconnectDevice(device: string): void {
        if (!device)
            return;
        forgetProc.command = ["nmcli", "device", "disconnect", device];
        forgetProc.running = true;
    }

    function disconnectFrom(ssid: string): void {
        forgetProc.command = ["nmcli", "connection", "down", ssid];
        forgetProc.running = true;
    }

    function forget(ssid: string): void {
        forgetProc.command = ["nmcli", "connection", "delete", ssid];
        forgetProc.running = true;
    }
}
