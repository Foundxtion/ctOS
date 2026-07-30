import QtQuick
import Quickshell.Hyprland

import "root:/config"

// Mirrors the way macOS shows the frontmost app's name right after the
// Apple logo. Hyprland doesn't have a concept of "current app menu", so
// this just shows the focused window's title, elided if it's long.
Item {
    id: root

    property int maxWidth: 320

    readonly property string title: {
        const t = Hyprland.activeToplevel;
        return t && t.title.length > 0 ? t.title : "Desktop";
    }

    implicitWidth: Math.min(label.implicitWidth, maxWidth) + 16
    implicitHeight: Appearance.barHeight - 8

    Text {
        id: label
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 8
        text: root.title
        color: Appearance.textPrimary
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeNormal
        font.bold: true
        elide: Text.ElideRight
        maximumLineCount: 1
    }
}
