import QtQuick

import "root:/config"

// A little pill toggle, like the switches in macOS System Settings / Control
// Center (Wi-Fi, Bluetooth, etc).
Item {
    id: root

    property bool checked: false
    signal toggled(bool checked)

    implicitWidth: 38
    implicitHeight: 22

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Appearance.accent : Qt.rgba(1, 1, 1, 0.18)

        Behavior on color {
            ColorAnimation { duration: Appearance.animNormal }
        }
    }

    Rectangle {
        id: knob
        width: parent.height - 4
        height: width
        radius: width / 2
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 2 : 2

        Behavior on x {
            NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
