import QtQuick

import "root:/config"

// The bold heading at the top of a Control Center panel, with room on the
// right for a control (usually the on/off switch for whatever the panel is).
Item {
    id: root

    property string text: ""
    property alias trailingContent: trailingSlot.data

    implicitWidth: parent ? parent.width : 260
    implicitHeight: 26

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.right: trailingSlot.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        color: Appearance.textPrimary
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeTitle
        font.bold: true
        elide: Text.ElideRight
    }

    Item {
        id: trailingSlot
        anchors.right: parent.right
        anchors.rightMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }
}
