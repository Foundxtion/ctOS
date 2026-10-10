import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "root:/config"
import "root:/services"
import "root:/widgets"
import "root:/widgets/icons"

// The heads-up display macOS shows when you press the volume or brightness
// keys: a translucent rounded square, a large glyph, and a bar of sixteen
// blocks underneath it. It sits low and centred, holds for about a second
// and a half, then fades.
//
// Sixteen blocks isn't arbitrary — that's how many steps macOS's own HUD
// has, which is why a 10% volume step lands the bar somewhere between
// blocks rather than snapping neatly. Set Settings.osdSegments to 10 if you
// would rather it lined up with your keybinds' step size than match Apple.
//
// The window takes no input at all. It's an overlay layer so it floats above
// fullscreen windows, and its input mask is empty, so clicks pass straight
// through to whatever is underneath — a HUD you have to dismiss would be
// worse than no HUD.
Scope {
    id: root

    // Optional IPC entry point. String URL rather than a type reference so a
    // mismatch with Quickshell's IPC API disables just this and logs, rather
    // than taking the shell down at load time.
    Loader {
        active: Settings.osdIpcEnabled
        source: "root:/services/OsdIpc.qml"
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: osdWindow
            required property var modelData
            screen: modelData

            // Same layer-shell namespace as the bar, so the blur rule you
            // already have in hypr/topbar.conf covers this too.
            WlrLayershell.namespace: "quickshell:topbar"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            // macOS puts the HUD on the display you're working on, not on
            // every screen at once. If the focused monitor can't be
            // determined, showing it everywhere is the safer failure.
            readonly property bool onThisScreen: {
                if (Settings.osdOnAllScreens)
                    return true;
                const focused = Hyprland.focusedMonitor?.name ?? "";
                return focused === "" || focused === modelData.name;
            }

            readonly property bool wanted: Osd.active && onThisScreen
            readonly property int shadowMargin: Appearance.shadowEnabled ? Appearance.shadowMargin : 0

            // Stays up while the fade-out is still running: dropping the
            // window the instant `wanted` goes false would cut the animation
            // off at full opacity.
            visible: wanted || panel.opacity > 0.01

            anchors.bottom: true
            margins.bottom: Settings.osdBottomMargin
            exclusiveZone: 0
            color: "transparent"

            implicitWidth: Settings.osdSize + shadowMargin * 2
            implicitHeight: Settings.osdSize + shadowMargin * 2

            // An empty region means no part of this surface accepts pointer
            // input, so the HUD never intercepts a click.
            mask: Region {}

            Item {
                id: panel
                anchors.centerIn: parent
                width: Settings.osdSize
                height: Settings.osdSize

                opacity: osdWindow.wanted ? 1 : 0

                // Snaps in, drifts out — the asymmetry is what makes it feel
                // responsive rather than laggy. The duration is read when the
                // animation starts, by which point `wanted` already holds the
                // new value.
                Behavior on opacity {
                    NumberAnimation {
                        duration: osdWindow.wanted ? 90 : 350
                        easing.type: Easing.OutCubic
                    }
                }

                Loader {
                    source: "root:/widgets/SoftShadow.qml"
                    active: Appearance.shadowEnabled
                    anchors.fill: card
                    z: -1
                    onLoaded: item.cornerRadius = Qt.binding(() => card.radius)
                }

                Rectangle {
                    id: card
                    anchors.fill: parent
                    radius: Appearance.osdRadius
                    color: Appearance.osdBackground
                    border.width: 1
                    border.color: Appearance.popupBorder
                }

                // ── Glyph ─────────────────────────────────────────
                Item {
                    id: glyphBox
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height * 0.66

                    readonly property real glyphSize: panel.height * 0.42

                    SpeakerIcon {
                        anchors.centerIn: parent
                        visible: Osd.kind !== "brightness"
                        size: glyphBox.glyphSize
                        muted: Osd.muted
                        level: {
                            if (Osd.percent === 0)
                                return 0;
                            return Osd.percent < 50 ? 1 : 2;
                        }
                        color: Appearance.textPrimary
                    }

                    SunIcon {
                        anchors.centerIn: parent
                        visible: Osd.kind === "brightness"
                        size: glyphBox.glyphSize
                        // Apple's own HUD keeps this glyph fixed and lets the
                        // bar carry the value; set osdSunFollowsLevel to false
                        // for that behaviour.
                        level: Settings.osdSunFollowsLevel ? (Osd.percent / 100) : 1.0
                        color: Appearance.textPrimary
                    }
                }

                // ── Segmented level bar ───────────────────────────
                Row {
                    id: segmentRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: Math.round(panel.height * 0.15)
                    spacing: 2

                    readonly property int filled: Osd.muted
                        ? 0
                        : Math.round(Math.max(0, Math.min(100, Osd.percent))
                                     / 100 * Settings.osdSegments)

                    Repeater {
                        model: Settings.osdSegments

                        Rectangle {
                            required property int index

                            width: (panel.width * 0.76
                                    - (Settings.osdSegments - 1) * segmentRow.spacing)
                                   / Settings.osdSegments
                            height: 8
                            radius: 1.5
                            color: index < segmentRow.filled
                                   ? Appearance.osdSegmentOn
                                   : Appearance.osdSegmentOff

                            Behavior on color {
                                ColorAnimation { duration: Appearance.animFast }
                            }
                        }
                    }
                }
            }
        }
    }
}
