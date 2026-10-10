pragma Singleton
import Quickshell
import QtQuick

import "root:/config"
import "root:/services"

// State behind the volume/brightness heads-up display.
//
// Nothing has to tell this service that you pressed a key: it watches the
// values themselves. PipeWire pushes volume changes, so those arrive the
// instant pactl applies them, whoever ran it. Brightness is polled out of
// sysfs by services/Brightness.qml. Either way your existing keybinds work
// unmodified — the display is a consequence of the value moving, not of the
// binding being run.
//
// Two things that follow from watching state rather than keystrokes, both
// worth knowing:
//
//   * A keypress that changes nothing shows nothing. Volume-up at 100% is
//     already at 100%, so no HUD appears, where macOS would flash one. The
//     optional IPC handler (services/OsdIpc.qml) exists for people who want
//     that case covered.
//   * Any other source of change shows the HUD too — including this shell's
//     own Sound panel. That's why the panel's sliders call suppress()
//     first; dragging a slider is its own feedback and doesn't need a
//     second one on top.
Singleton {
    id: root

    // "volume" | "brightness" | ""
    property string kind: ""
    property bool active: false

    readonly property int percent: kind === "brightness"
                                   ? Brightness.percent
                                   : Audio.volumePercent
    readonly property bool muted: kind === "volume" && Audio.muted

    // Values settle during startup — volume arrives from PipeWire, the
    // backlight from its first read — and none of that is a user action.
    property bool ready: false
    property real suppressUntil: 0

    function show(which: string): void {
        if (!Settings.osdEnabled || !ready)
            return;
        if (Date.now() < suppressUntil)
            return;
        kind = which;
        active = true;
        hideTimer.restart();
    }

    // Blocks the display briefly — for changes the user is already watching
    // themselves, like a slider drag.
    function suppress(ms: int): void {
        suppressUntil = Date.now() + (ms > 0 ? ms : 700);
        active = false;
    }

    Timer {
        id: hideTimer
        interval: Settings.osdTimeout
        onTriggered: root.active = false
    }

    Timer {
        id: readyTimer
        interval: 1500
        running: true
        onTriggered: root.ready = true
    }

    Connections {
        target: Audio

        function onVolumePercentChanged(): void {
            root.show("volume");
        }

        function onMutedChanged(): void {
            root.show("volume");
        }
    }

    Connections {
        target: Brightness

        function onPercentChanged(): void {
            // The first successful read is the value becoming known, not
            // the user changing it.
            if (Brightness.loaded)
                root.show("brightness");
        }
    }
}
