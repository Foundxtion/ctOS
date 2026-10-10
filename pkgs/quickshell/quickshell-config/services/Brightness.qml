pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

import "root:/config"

// Display backlight, read straight from sysfs and written through
// brightnessctl.
//
// Discovery runs once at startup and asks brightnessctl which device it
// would use — on machines exposing both acpi_video0 and intel_backlight
// that answer is the one that actually works, and guessing wrong means a
// slider that moves nothing. If brightnessctl isn't installed the first
// entry in /sys/class/backlight is used instead.
//
// After that the current value is read directly out of sysfs rather than by
// shelling out: a FileView reload is a plain file read, while polling
// `brightnessctl -m` several times a second would fork a process each time.
// That distinction is the whole reason the poll interval can be short
// enough for the on-screen display to feel instant.
Singleton {
    id: root

    property string device: ""
    property int max: 0
    property int raw: -1

    readonly property bool available: device !== "" && max > 0
    readonly property int percent: (available && raw >= 0)
                                   ? Math.round(raw / max * 100)
                                   : 0

    // True once a real value has been read at least once, so the OSD can
    // tell "brightness changed" apart from "brightness became known".
    property bool loaded: false

    readonly property string discoverScript: `
        if command -v brightnessctl >/dev/null 2>&1; then
            brightnessctl -m 2>/dev/null | head -n1 | awk -F, '{print $1 "|" $5}'
        else
            d=$(ls -1 /sys/class/backlight 2>/dev/null | head -n1)
            if [ -n "$d" ]; then
                printf '%s|%s\\n' "$d" "$(cat /sys/class/backlight/$d/max_brightness 2>/dev/null)"
            fi
        fi
    `

    Process {
        id: discoverProc
        running: true
        command: ["sh", "-c", root.discoverScript]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split("|");
                if (parts.length < 2)
                    return;
                const maxValue = parseInt(parts[1], 10);
                if (!parts[0] || isNaN(maxValue) || maxValue <= 0)
                    return;
                root.device = parts[0];
                root.max = maxValue;
            }
        }
    }

    FileView {
        id: brightnessFile
        path: root.device !== ""
              ? "/sys/class/backlight/" + root.device + "/brightness"
              : ""
        // sysfs reads never fail interestingly and they'd otherwise spam the
        // log once per poll on a machine with no backlight.
        printErrors: false

        onLoaded: {
            const value = parseInt(root.readFile(this), 10);
            if (isNaN(value))
                return;
            root.raw = value;
            root.loaded = true;
        }
    }

    // Kept as its own function so a FileView API change is a one-line fix
    // rather than a hunt.
    function readFile(view: var): string {
        return view.text();
    }

    Timer {
        // Short enough that holding the brightness key looks continuous.
        // Set Settings.brightnessPollInterval to 0 to switch polling off
        // entirely — worth doing if you drive the OSD over IPC instead.
        interval: Settings.brightnessPollInterval
        running: root.available && Settings.brightnessPollInterval > 0
        repeat: true
        onTriggered: brightnessFile.reload()
    }

    function setPercent(p: int): void {
        if (!available)
            return;
        const clamped = Math.max(1, Math.min(100, Math.round(p)));
        Quickshell.execDetached(["brightnessctl", "s", clamped + "%"]);
        brightnessFile.reload();
    }

    function nudge(deltaPercent: int): void {
        setPercent(percent + deltaPercent);
    }
}
