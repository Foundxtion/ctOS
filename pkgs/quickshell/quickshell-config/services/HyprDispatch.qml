pragma Singleton
import Quickshell
import Quickshell.Hyprland

// Hyprland 0.55 replaced hyprlang (.conf) with a Lua config, and the old
// plain dispatcher strings ("workspace 2", "exit") are rejected over IPC
// once Hyprland is running in Lua mode — they now need to be sent as Lua
// call expressions instead (e.g. "hl.dsp.focus({ workspace = 2 })").
// See: https://github.com/Alexays/Waybar/issues/5008 (same break, in Waybar)
//
// This only wraps the two dispatchers this shell actually issues. Both
// Lua-mode forms below are taken directly from Hyprland's own example
// config: https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua
// ("hl.dsp.focus({ workspace = i })" for switching, "hl.dsp.exit()" for
// the exit bind's hyprctl fallback).
//
// Hyprland.usingLua tells us which mode we're in at runtime, so this one
// file handles both — nothing else in the project needs to know or care.
Singleton {
    function workspace(id: int): void {
        if (Hyprland.usingLua)
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })");
        else
            Hyprland.dispatch("workspace " + id);
    }

    function exit(): void {
        if (Hyprland.usingLua)
            Hyprland.dispatch("hl.dsp.exit()");
        else
            Hyprland.dispatch("exit");
    }
}
