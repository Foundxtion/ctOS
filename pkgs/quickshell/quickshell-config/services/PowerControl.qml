pragma Singleton
import Quickshell

import "root:/config"
import "root:/services"

// Session/power actions for the Apple menu, and the Spotlight launcher hook.
// Everything here is fire-and-forget (Quickshell.execDetached), matching how
// a real menu bar behaves — click it, it happens, no confirmation dialogs.
Singleton {
    function openSpotlight(): void {
        Quickshell.execDetached(Settings.spotlightCommand);
    }

    function lockScreen(): void {
        Quickshell.execDetached(Settings.lockCommand);
    }

    function sleep(): void {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function restart(): void {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function shutdown(): void {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    function logOut(): void {
        // Ends the Hyprland session. Routed through HyprDispatch since the
        // raw "exit" dispatcher string only works under hyprlang configs —
        // Hyprland 0.55+'s Lua config needs a different form.
        HyprDispatch.exit();
    }

    function reloadHyprland(): void {
        // `hyprctl reload` is a utility subcommand, not a dispatcher, so it
        // can't go through Hyprland.dispatch() — it needs to run as a
        // real process.
        Quickshell.execDetached(["hyprctl", "reload"]);
    }
}
