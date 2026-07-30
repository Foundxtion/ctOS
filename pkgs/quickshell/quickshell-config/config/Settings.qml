pragma Singleton
import Quickshell

// Things you are likely to want to tweak for your own machine.
Singleton {
    // The command used for your existing rofi-based Spotlight replacement.
    // Whatever you currently bind in hyprland.conf, put the same argv here
    // (as a list — one array element per shell word, no quoting needed).
    readonly property list<string> spotlightCommand: ["rofi", "-show", "drun", "-show-icons"]

    // Screen locker invoked from the  Apple menu. Swap for "swaylock" or
    // your own script if you're not using hyprlock.
    readonly property list<string> lockCommand: ["hyprlock"]

    // Show the Spotlight glass icon in the bar (in addition to your existing
    // rofi keybind). Set to false if you'd rather keep the bar minimal.
    readonly property bool showSpotlightIcon: true

    // Show workspace pills in the center of the bar.
    readonly property bool showWorkspaces: true

    // Number of workspace slots to always reserve room for (Hyprland will
    // happily go higher; this just controls the default pill count so the
    // bar doesn't jump around as you create workspaces).
    readonly property int workspaceCount: 5

    // Show the focused window's title next to the Apple menu, like macOS
    // shows the frontmost app's name.
    readonly property bool showActiveWindow: true

    // ── Menus ───────────────────────────────────────────────────────
    // macOS menus have no icons at all — labels only. Flip this on if you
    // preferred the icon-per-row look; every MenuItem already carries a
    // glyph, it just isn't drawn by default.
    readonly property bool menuShowIcons: false

    // ── Bluetooth ───────────────────────────────────────────────────
    // Hide the Bluetooth module entirely (it also hides itself when no
    // adapter is present, so this is only for machines that have one and
    // don't want it in the bar).
    readonly property bool showBluetooth: true

    // How long a "Scan" runs for, in seconds.
    readonly property int bluetoothScanSeconds: 12

    // ── Network ─────────────────────────────────────────────────────
    // Refresh interval for Wi-Fi scans while the popup is open (ms).
    readonly property int wifiScanInterval: 8000

    // How often throughput is sampled while the Wi-Fi panel is open (ms).
    // 1000 gives the live, immediate feel; raise it if you want calmer
    // numbers. Note the readout is a rate over the sampling window, so a
    // longer window means a smoother, laggier figure.
    readonly property int throughputInterval: 1000

    // Show throughput as bits/s (what routers and ISPs quote) instead of
    // bytes/s (what macOS's own Activity Monitor shows).
    readonly property bool throughputInBits: false

    // Interfaces never worth showing as "your connection".
    readonly property var ignoredInterfaces: ["lo"]

    // Clock format. See Qt date format docs for tokens.
    readonly property string clockFormat: "ddd d MMM  h:mm AP"
}
