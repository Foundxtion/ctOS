import QtQuick

import "root:/config"

// The macOS battery: a thin rounded shell, a fill that shortens as the
// charge drops, and the little anode nub on the right. Pulled out of
// BatteryButton so the bar icon and the Battery panel draw the identical
// shape at different sizes.
Item {
    id: root

    // 0.0 .. 1.0
    property real charge: 0
    property bool charging: false
    property bool low: false
    property color color: Appearance.textPrimary
    property real scaleFactor: 1.0

    implicitWidth: 25 * scaleFactor
    implicitHeight: 12 * scaleFactor

    readonly property color fillColor: root.charging ? Appearance.accentGreen
                                       : (root.low ? Appearance.accentRed : root.color)

    // Shell
    Rectangle {
        id: shell
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width - 3 * root.scaleFactor
        color: "transparent"
        border.color: Qt.rgba(root.color.r, root.color.g, root.color.b, root.color.a * 0.55)
        border.width: Math.max(1, 1 * root.scaleFactor)
        radius: 3.5 * root.scaleFactor

        // Charge level
        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 2 * root.scaleFactor
            width: Math.max(0, (parent.width - 4 * root.scaleFactor) * Math.max(0, Math.min(1, root.charge)))
            color: root.fillColor
            radius: 1.5 * root.scaleFactor

            Behavior on width {
                NumberAnimation { duration: Appearance.animNormal }
            }
        }
    }

    // Anode nub
    Rectangle {
        width: 2 * root.scaleFactor
        height: 4.5 * root.scaleFactor
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: Qt.rgba(root.color.r, root.color.g, root.color.b, root.color.a * 0.55)
        radius: 1 * root.scaleFactor
    }
}
