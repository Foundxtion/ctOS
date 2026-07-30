import QtQuick
import Quickshell
import Quickshell.Wayland

import "root:/config"
import "root:/services"
import "root:/widgets"
import "root:/modules/bar"
import "root:/modules/popups"

// One PanelWindow per connected screen, each with its own popup state so
// opening the Wi-Fi menu on monitor 2 doesn't affect monitor 1.
Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            WlrLayershell.namespace: "quickshell:topbar"
            // Layer-shell surfaces take no keyboard focus by default, which
            // silently breaks typing into anything inside a popup (e.g. the
            // Wi-Fi password field). OnDemand only takes focus when
            // something actually wants it (a focused TextField), unlike
            // Exclusive which would hijack the keyboard permanently.
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: Appearance.barHeight + Appearance.barMargin
            exclusiveZone: Appearance.barHeight + Appearance.barMargin
            color: "transparent"

            // "" | "apple" | "bluetooth" | "wifi" | "sound" | "battery"
            property string openPopup: ""
            function togglePopup(name: string): void {
                openPopup = (openPopup === name) ? "" : name;
            }

            // ── Bar surface ───────────────────────────────────────
            // With Appearance.barMargin at its default of 0 this is just
            // anchors.fill: parent in practice — written as margins instead
            // so bumping barMargin for the floating-pill look (see
            // Appearance.qml) works without touching this file.
            Rectangle {
                id: barSurface
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: Appearance.barMargin
                height: Appearance.barHeight
                radius: Appearance.barRadius
                color: Appearance.barBackground
                border.width: 1
                border.color: Appearance.barBorder

                // ── Left: Apple menu + focused app name ───────────
                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 6
                    spacing: Appearance.itemSpacing

                    AppleMenuButton {
                        id: appleBtn
                        active: barWindow.openPopup === "apple"
                        onClicked: barWindow.togglePopup("apple")
                    }

                    ActiveWindowTitle {
                        visible: Settings.showActiveWindow
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // ── Center: Hyprland workspaces ───────────────────
                Workspaces {
                    anchors.centerIn: parent
                    visible: Settings.showWorkspaces
                }

                // ── Right: status items, in macOS menu-bar order ──
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 6
                    spacing: Appearance.itemSpacing

                    SpotlightButton {
                        visible: Settings.showSpotlightIcon
                    }

                    BluetoothButton {
                        id: bluetoothBtn
                        active: barWindow.openPopup === "bluetooth"
                        onClicked: barWindow.togglePopup("bluetooth")
                    }

                    WifiButton {
                        id: wifiBtn
                        active: barWindow.openPopup === "wifi"
                        onClicked: barWindow.togglePopup("wifi")
                    }

                    SoundButton {
                        id: soundBtn
                        active: barWindow.openPopup === "sound"
                        onClicked: barWindow.togglePopup("sound")
                    }

                    BatteryButton {
                        id: batteryBtn
                        active: barWindow.openPopup === "battery"
                        onClicked: barWindow.togglePopup("battery")
                    }

                    Clock {
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // ── Dropdowns ─────────────────────────────────────────
            // The Apple menu is the one true *menu* here; everything else
            // is a Control Center panel, which is why only it sets
            // menuStyle.
            PopupCard {
                anchorItem: appleBtn
                alignment: "left"
                cardWidth: 210
                menuStyle: true
                shown: barWindow.openPopup === "apple"
                onDismissed: barWindow.openPopup = ""

                AppleMenuPopup {
                    onRequestClose: barWindow.openPopup = ""
                }
            }

            PopupCard {
                anchorItem: bluetoothBtn
                alignment: "right"
                cardWidth: 300
                shown: barWindow.openPopup === "bluetooth"
                onDismissed: barWindow.openPopup = ""

                BluetoothPopup {
                    // Lets the service poll quickly while you're watching
                    // and back off when you aren't.
                    active: barWindow.openPopup === "bluetooth"
                }
            }

            PopupCard {
                anchorItem: wifiBtn
                alignment: "right"
                cardWidth: 320
                shown: barWindow.openPopup === "wifi"
                onDismissed: barWindow.openPopup = ""

                WifiPopup {
                    active: barWindow.openPopup === "wifi"
                }
            }

            PopupCard {
                anchorItem: soundBtn
                alignment: "right"
                cardWidth: 300
                shown: barWindow.openPopup === "sound"
                onDismissed: barWindow.openPopup = ""

                SoundPopup {}
            }

            PopupCard {
                anchorItem: batteryBtn
                alignment: "right"
                cardWidth: 270
                shown: barWindow.openPopup === "battery"
                onDismissed: barWindow.openPopup = ""

                BatteryPopup {}
            }
        }
    }
}
