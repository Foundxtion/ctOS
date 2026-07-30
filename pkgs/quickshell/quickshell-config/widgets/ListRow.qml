import QtQuick

import "root:/config"

// One row of a Control Center list: a round icon well on the left, a title
// with an optional second line under it, and a slot on the right for a
// checkmark, a padlock, a battery figure — whatever the list needs.
//
// The whole row is the hit target, and the hover highlight is a rounded
// rectangle rather than a full-bleed band, which is what distinguishes a
// Control Center list from a menu.
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool selected: false
    property bool interactive: true
    property bool busy: false

    default property alias leadingContent: leadingSlot.data
    property alias trailingContent: trailingSlot.data

    signal clicked

    implicitWidth: parent ? parent.width : 260
    implicitHeight: subtitle.length > 0 ? 42 : Appearance.rowHeight

    Rectangle {
        anchors.fill: parent
        radius: Appearance.rowRadius
        color: root.interactive && mouseArea.containsMouse
               ? (mouseArea.pressed ? Appearance.pressFill : Appearance.hoverFill)
               : "transparent"

        Behavior on color {
            ColorAnimation { duration: Appearance.animFast }
        }
    }

    Item {
        id: leadingSlot
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }

    Column {
        anchors.left: leadingSlot.right
        anchors.leftMargin: 9
        anchors.right: trailingSlot.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            width: parent.width
            text: root.title
            color: Appearance.textPrimary
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSizeNormal
            font.weight: root.selected ? Font.DemiBold : Font.Normal
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            visible: root.subtitle.length > 0
            text: root.subtitle
            color: Appearance.textSecondary
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSizeSmall
            elide: Text.ElideRight
        }
    }

    Item {
        id: trailingSlot
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
