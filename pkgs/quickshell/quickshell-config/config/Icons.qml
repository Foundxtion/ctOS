pragma Singleton
import Quickshell

// The few glyphs still taken from the Nerd Font.
//
// Everything with a distinctive macOS silhouette — Wi-Fi, Bluetooth, the
// speaker, the battery, checkmarks, padlocks — is now drawn as vector
// geometry in widgets/icons/ instead. Font glyphs were never going to match
// Apple's shapes, they can't respond to state (signal strength, wave count,
// charge level) without swapping to a different codepoint, and a font
// missing one glyph set put a tofu box in the middle of the bar.
//
// What's left here is the Apple logo, which has no sensible vector
// substitute, plus the optional per-row menu icons (off by default — see
// Settings.menuShowIcons). These come from the Font Awesome 4 set bundled
// into every Nerd Font (codepoints f000-f2e0), the most universally
// included glyph range. If one renders as a box, look it up at
// https://www.nerdfonts.com/cheat-sheet and swap the codepoint below.
Singleton {
    // Apple / system
    readonly property string apple: "\uf179"        // nf-fa-apple

    // Apple-menu actions (only drawn when Settings.menuShowIcons is on)
    readonly property string lock: "\uf023"          // nf-fa-lock
    readonly property string moon: "\uf186"          // nf-fa-moon_o        (sleep)
    readonly property string refresh: "\uf021"       // nf-fa-refresh       (reload Hyprland)
    readonly property string power: "\uf011"         // nf-fa-power_off     (shut down)
    readonly property string restart: "\uf01e"       // nf-fa-repeat        (restart)
    readonly property string logout: "\uf08b"        // nf-fa-sign_out      (log out)
    readonly property string gear: "\uf013"          // nf-fa-cog           (settings)

    // Bar controls
    readonly property string search: "\uf002"        // nf-fa-search        (Spotlight)
}
