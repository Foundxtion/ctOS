import QtQuick

import "root:/config"

// The hairline between menu groups. macOS insets it slightly from the menu
// edges rather than running it wall to wall, and pads it with a few pixels
// of air on each side so groups read as groups.
Item {
    id: root

    property int inset: 9
    property int spacing: 5

    implicitWidth: parent ? parent.width : 200
    implicitHeight: 1 + spacing * 2

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.inset
        anchors.rightMargin: root.inset
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        color: Appearance.separator
    }
}
