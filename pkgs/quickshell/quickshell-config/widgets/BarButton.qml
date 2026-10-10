import QtQuick

import "root:/config"

// The clickable "hit target" for every bar module (Apple menu, Wi-Fi,
// volume, battery, Spotlight...). Handles hover/press highlighting and
// exposes itself as `root` so callers can anchor a popup to `this` item.
Item {
    id: root

    default property alias content: contentRow.data
    property bool active: false     // true while this item's popup is open
    property int horizontalPadding: Appearance.itemPadding

    signal clicked

    implicitWidth: contentRow.implicitWidth + horizontalPadding * 2
    implicitHeight: Appearance.barHeight - 8

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Appearance.itemRadius
        color: root.active
               ? Appearance.activeFill
               : (mouseArea.pressed ? Appearance.pressFill
                  : (mouseArea.containsMouse ? Appearance.hoverFill : "transparent"))

        Behavior on color {
            ColorAnimation { duration: Appearance.animFast }
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 5
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
