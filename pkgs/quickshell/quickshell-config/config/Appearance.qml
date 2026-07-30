pragma Singleton
import Quickshell
import QtQuick

// Central design tokens, modeled after macOS Sequoia's menu bar, its menus,
// and Control Center. Change values here to re-theme the whole bar from one
// place.
Singleton {
    id: root

    // ── Bar geometry ────────────────────────────────────────────────
    readonly property int barHeight: 40
    // Real macOS menu bars are flush, edge-to-edge, unrounded. Both are 0
    // by default; bump them if you'd rather have the "floating pill" bar
    // look popular in Hyprland rices — Bar.qml already reads these.
    readonly property int barMargin: -2
    readonly property int barRadius: 0
    readonly property int itemRadius: 7          // hover pill radius for bar buttons
    readonly property int itemSpacing: 2
    readonly property int itemPadding: 7
    readonly property int iconSize: 20

    // ── Popup geometry ──────────────────────────────────────────────
    // Two distinct shapes, because macOS has two distinct dropdown kinds:
    //
    //   menuStyle  — the Apple menu. Small radius, near-zero padding, rows
    //                that run edge to edge and highlight in accent blue.
    //   card style — Control Center panels (Wi-Fi, Bluetooth, Sound...).
    //                Big radius, generous padding, grouped sections.
    readonly property int popupRadius: 16        // Control Center cards
    readonly property int popupPadding: 14
    readonly property int popupSpacing: 10
    readonly property int popupGap: 6            // gap between bar and dropdown

    readonly property int menuRadius: 10         // Apple-menu style menus
    readonly property int menuPadding: 5
    readonly property int menuItemHeight: 24
    readonly property int menuItemRadius: 6

    readonly property int rowHeight: 34          // a Control Center list row
    readonly property int rowRadius: 9
    readonly property int circleSize: 26         // the round icon well in a row

    // ── Drop shadow ─────────────────────────────────────────────────
    // macOS menus float on a wide, soft shadow. The popup window has to be
    // physically larger than its card for the blur to have somewhere to
    // land, so shadowMargin is transparent padding baked into every popup
    // window (PopupCard.qml compensates its anchoring for it).
    //
    // If popups ever land in the wrong place, set shadowEnabled to false —
    // that collapses shadowMargin to 0 and restores flush anchoring.
    readonly property bool shadowEnabled: true
    readonly property int shadowMargin: 18
    readonly property real shadowBlurMax: 32
    readonly property real shadowOpacity: 0.45
    readonly property int shadowOffset: 5

    // ── Colors: bar ─────────────────────────────────────────────────
    // Actual translucency + the frosted look comes from the compositor blur
    // (see hypr/topbar.conf) — these alpha values just need to look right
    // on top of a blurred background.
    readonly property color barBackground: Qt.rgba(0.09, 0.09, 0.10, 0.55)
    readonly property color barBorder: Qt.rgba(1, 1, 1, 0.07)

    // ── Colors: popups ──────────────────────────────────────────────
    readonly property color popupBackground: Qt.rgba(0.11, 0.11, 0.12, 0.78)
    readonly property color menuBackground: Qt.rgba(0.13, 0.13, 0.14, 0.76)
    readonly property color popupBorder: Qt.rgba(1, 1, 1, 0.09)
    readonly property color popupShadow: Qt.rgba(0, 0, 0, 1)

    // Grouped "inset panel" inside a Control Center card — the block the
    // connection summary sits in.
    readonly property color groupBackground: Qt.rgba(1, 1, 1, 0.06)
    readonly property color fieldBackground: Qt.rgba(1, 1, 1, 0.09)
    readonly property color circleIdle: Qt.rgba(1, 1, 1, 0.16)

    // ── Colors: content ─────────────────────────────────────────────
    readonly property color textPrimary: Qt.rgba(1, 1, 1, 0.94)
    readonly property color textSecondary: Qt.rgba(1, 1, 1, 0.55)
    readonly property color textDisabled: Qt.rgba(1, 1, 1, 0.30)
    readonly property color textOnAccent: "#FFFFFF"

    readonly property color accent: "#0A84FF"        // macOS system blue
    readonly property color accentGreen: "#30D158"   // charging / good state
    readonly property color accentYellow: "#FFD60A"  // low-power / warnings
    readonly property color accentRed: "#FF453A"     // critical / destructive

    readonly property color hoverFill: Qt.rgba(1, 1, 1, 0.10)
    readonly property color pressFill: Qt.rgba(1, 1, 1, 0.16)
    readonly property color activeFill: Qt.rgba(1, 1, 1, 0.16) // bar button while its popup is open
    readonly property color separator: Qt.rgba(1, 1, 1, 0.11)

    // Control Center sliders fill white, not accent blue — the blue fill is
    // a Windows/GNOME convention, macOS uses white on a dim track.
    readonly property color sliderFill: Qt.rgba(1, 1, 1, 0.92)
    readonly property color sliderTrack: Qt.rgba(1, 1, 1, 0.14)

    // ── Typography ──────────────────────────────────────────────────
    // Set this to any font you like. It only needs to look clean — it does
    // not need to be a Nerd Font, since icons come from iconFontFamily below.
    readonly property string fontFamily: "SF Pro Display, Inter, sans-serif"
    readonly property real fontSizeSmall: 11
    readonly property real fontSizeNormal: 12.5
    readonly property real fontSizeLarge: 14
    readonly property real fontSizeMenu: 13          // macOS menu row text
    readonly property real fontSizeTitle: 15         // Control Center panel title

    // This DOES need to be a Nerd Font (v3+) for the glyphs in config/Icons.qml
    // to render. Change to whatever you have installed, e.g.
    // "JetBrainsMono Nerd Font", "FiraCode Nerd Font", "Hack Nerd Font"...
    //
    // Only the Apple logo still comes from here — every other icon in the
    // bar is now drawn as vector geometry in widgets/icons/, so a missing
    // glyph set can no longer put a tofu box in the middle of the bar.
    readonly property string iconFontFamily: "JetBrainsMono Nerd Font"

    // ── Animation ───────────────────────────────────────────────────
    readonly property int animFast: 100
    readonly property int animNormal: 160
    readonly property int animPopup: 110
}
