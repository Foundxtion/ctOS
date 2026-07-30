import QtQuick

import "root:/config"

Item {
    id: root

    property date now: new Date()

    implicitWidth: label.implicitWidth + 4
    implicitHeight: Appearance.barHeight - 8

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: Qt.formatDateTime(root.now, Settings.clockFormat)
        color: Appearance.textPrimary
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeNormal
    }
}
