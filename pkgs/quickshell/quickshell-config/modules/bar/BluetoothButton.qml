import QtQuick

import "root:/config"
import "root:/services"
import "root:/widgets"
import "root:/widgets/icons"

// Bluetooth status. Hidden entirely on machines with no adapter, dimmed
// with a bar through it when the radio is off, and tinted accent blue while
// something is actually connected — the one state macOS bothers to
// colour-code in the menu bar.
BarButton {
    id: root

    visible: Settings.showBluetooth && Bluetooth.available

    BluetoothIcon {
        anchors.verticalCenter: parent.verticalCenter
        size: Appearance.iconSize
        slashed: !Bluetooth.powered
        color: !Bluetooth.powered
               ? Appearance.textDisabled
               : (Bluetooth.anyConnected ? Appearance.accent : Appearance.textPrimary)
    }
}
