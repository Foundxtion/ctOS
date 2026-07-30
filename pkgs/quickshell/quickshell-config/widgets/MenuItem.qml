import QtQuick

import "root:/config"
import "root:/widgets/icons"

// A single row in a macOS-style menu.
//
// The real thing is plainer than it looks: no icons, 13px text, a 24px row,
// and a rounded accent-blue highlight that follows the pointer with the
// label flipping to white on top of it. Checkmarks sit in a fixed column to
// the left so labels stay aligned whether or not a row is checked, and
// shortcut hints are right-aligned in a dimmer weight.
//
// Icons are off by default because macOS menus don't have them; flip
// Settings.menuShowIcons if you prefer the icon look, and any row with an
// `icon` set will render it in the checkmark column.
Rectangle {
    id: root

    property string label: ""
    property string icon: ""            // Nerd Font glyph, only drawn if menuShowIcons
    property string shortcut: ""        // right-aligned hint, e.g. "⌘Q"
    property bool checked: false
    property bool enabled: true
    property bool highlightable: true

    signal clicked

    implicitWidth: 220
    implicitHeight: Appearance.menuItemHeight
    radius: Appearance.menuItemRadius

    readonly property bool hot: highlightable && enabled && mouseArea.containsMouse

    color: hot ? Appearance.accent : "transparent"
    opacity: enabled ? 1.0 : 0.35

    Behavior on color {
        ColorAnimation { duration: Appearance.animFast }
    }

    // ── Leading column: checkmark, or an icon if you've enabled them ──
    Item {
        id: leading
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: 13
        height: 13

        CheckIcon {
            anchors.centerIn: parent
            visible: root.checked
            size: 12
            color: root.hot ? Appearance.textOnAccent : Appearance.textPrimary
        }

        NerdIcon {
            anchors.centerIn: parent
            visible: !root.checked && Settings.menuShowIcons && root.icon.length > 0
            text: root.icon
            size: 12
            iconColor: root.hot ? Appearance.textOnAccent : Appearance.textSecondary
        }
    }

    Text {
        id: labelText
        anchors.left: leading.right
        anchors.leftMargin: 6
        anchors.right: shortcutText.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: root.hot ? Appearance.textOnAccent : Appearance.textPrimary
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeMenu
        elide: Text.ElideRight
    }

    Text {
        id: shortcutText
        anchors.right: parent.right
        anchors.rightMargin: 9
        anchors.verticalCenter: parent.verticalCenter
        text: root.shortcut
        visible: root.shortcut.length > 0
        color: root.hot ? Qt.rgba(1, 1, 1, 0.75) : Appearance.textSecondary
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeMenu
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
