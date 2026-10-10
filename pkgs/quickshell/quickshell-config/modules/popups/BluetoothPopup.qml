import QtQuick

import "root:/config"
import "root:/services"
import "root:/widgets"
import "root:/widgets/icons"

// The Bluetooth panel. Paired devices sit under "My Devices" and stay there
// whether or not they're currently connected — that's the list you actually
// use, and tapping a row toggles the connection. Anything else the adapter
// can currently see is grouped separately below, and only appears once
// you've asked it to look.
Column {
    id: root
    width: parent ? parent.width : 300
    spacing: Appearance.popupSpacing

    property bool active: false

    onActiveChanged: {
        if (active) {
            Bluetooth.addMonitor();
            Bluetooth.refresh();
        } else {
            Bluetooth.removeMonitor();
        }
    }

    function statusLine(device: var): string {
        const state = device.connected ? "Connected" : "Not Connected";
        return device.battery >= 0 ? state + " \u00b7 " + device.battery + "%" : state;
    }

    PanelTitle {
        width: root.width
        text: "Bluetooth"

        trailingContent: ToggleSwitch {
            checked: Bluetooth.powered
            onToggled: Bluetooth.togglePower()
        }
    }

    Text {
        width: root.width
        visible: !Bluetooth.powered
        text: "Bluetooth is off"
        color: Appearance.textSecondary
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeNormal
        leftPadding: 4
        bottomPadding: 4
    }

    // ── Paired devices ────────────────────────────────────────────
    SectionHeader {
        text: "My Devices"
        visible: Bluetooth.powered
    }

    Column {
        width: root.width
        spacing: 0
        visible: Bluetooth.powered

        Repeater {
            model: Bluetooth.knownDevices

            ListRow {
                id: knownRow
                required property var modelData

                width: root.width
                title: modelData.name
                subtitle: root.statusLine(modelData)
                selected: modelData.connected
                onClicked: {
                    if (modelData.connected)
                        Bluetooth.disconnectDevice(modelData.mac);
                    else
                        Bluetooth.connectDevice(modelData.mac, true);
                }

                IconWell {
                    highlighted: knownRow.modelData.connected

                    BluetoothIcon {
                        anchors.centerIn: parent
                        size: 15
                        color: knownRow.modelData.connected
                               ? Appearance.textOnAccent
                               : Appearance.textPrimary
                    }
                }
            }
        }

        Text {
            width: root.width
            visible: Bluetooth.knownDevices.length === 0
            text: "No paired devices"
            color: Appearance.textSecondary
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSizeSmall
            leftPadding: 8
            topPadding: 4
            bottomPadding: 4
        }
    }

    SectionDivider {
        spacing: 0
        visible: Bluetooth.powered
    }

    // ── Discovery ─────────────────────────────────────────────────
    Item {
        width: root.width
        height: 20
        visible: Bluetooth.powered

        SectionHeader {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: Bluetooth.scanning ? "Looking for devices\u2026" : "Other Devices"
        }

        Text {
            id: scanButton
            anchors.right: parent.right
            anchors.rightMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            text: Bluetooth.scanning ? "Scanning" : "Scan"
            color: Bluetooth.scanning
                   ? Appearance.textDisabled
                   : (scanMouse.containsMouse ? Qt.lighter(Appearance.accent, 1.2) : Appearance.accent)
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSizeSmall
            font.weight: Font.DemiBold

            MouseArea {
                id: scanMouse
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                enabled: !Bluetooth.scanning
                cursorShape: Qt.PointingHandCursor
                onClicked: Bluetooth.scan()
            }
        }
    }

    Column {
        width: root.width
        spacing: 0
        visible: Bluetooth.powered

        Repeater {
            model: Bluetooth.nearbyDevices

            ListRow {
                id: nearbyRow
                required property var modelData

                width: root.width
                title: modelData.name
                // Pairing is the real action here, so the row says so
                // rather than reporting a connection state that can't
                // exist yet.
                subtitle: "Tap to pair"
                onClicked: Bluetooth.connectDevice(modelData.mac, false)

                IconWell {
                    highlighted: false

                    BluetoothIcon {
                        anchors.centerIn: parent
                        size: 15
                        color: Appearance.textPrimary
                    }
                }
            }
        }

        Text {
            width: root.width
            visible: Bluetooth.nearbyDevices.length === 0 && !Bluetooth.scanning
            text: "Nothing else in range"
            color: Appearance.textSecondary
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSizeSmall
            leftPadding: 8
            topPadding: 4
            bottomPadding: 4
        }
    }
}
