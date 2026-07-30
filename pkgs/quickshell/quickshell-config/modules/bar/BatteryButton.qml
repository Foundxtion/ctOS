import QtQuick

import "root:/config"
import "root:/services"
import "root:/widgets"
import "root:/widgets/icons"

BarButton {
    id: root
    // isLaptopBattery isn't always reliably reported by every UPower
    // backend, so this is a slightly looser check: show the module whenever
    // UPower has a real, populated battery reading, rather than strictly
    // requiring the laptop-battery classification. On a genuine desktop
    // with no battery this stays false either way.
    visible: Battery.ready && Battery.percentInt > 0

    // The children sit in a Row (see BarButton.qml) whose default behavior
    // only manages x-position — each child's own natural height differs, so
    // without an explicit vertical anchor each one lands at a different y
    // and only coincidentally lines up.

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Battery.percentInt + "%"
        color: Appearance.textPrimary
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeNormal
    }

    BatteryIcon {
        anchors.verticalCenter: parent.verticalCenter
        charge: Battery.percentInt / 100
        charging: Battery.charging
        low: Battery.isLow
        color: Appearance.textPrimary
    }
}
