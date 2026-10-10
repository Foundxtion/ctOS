import Quickshell
import Quickshell.Io

import "root:/services"

// Optional: lets a keybind force the HUD up, whether or not the underlying
// value actually moved. Useful for the one case value-watching can't catch —
// pressing volume-up when you're already at 100%, where macOS still flashes
// the display.
//
// Loaded through a Loader with a string URL (see modules/OsdOverlay.qml), so
// if this file is wrong about Quickshell's IPC API the Loader reports an
// error and everything else carries on working.
//
// Call it from Hyprland with:
//   qs -c macos-topbar ipc call osd volume
//   qs -c macos-topbar ipc call osd brightness
//
// Check the names your build actually exposes with:
//   qs -c macos-topbar ipc show
IpcHandler {
    target: "osd"

    function volume(): void {
        Osd.show("volume");
    }

    function brightness(): void {
        Osd.show("brightness");
    }
}
