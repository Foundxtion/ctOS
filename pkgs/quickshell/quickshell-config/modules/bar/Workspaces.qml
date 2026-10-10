import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

import "root:/config"
import "root:/services"
import "root:/widgets"

// A row of dots representing numbered Hyprland workspaces — click one to
// jump to it. This is the one piece of the bar with no real macOS
// equivalent, kept deliberately understated so it doesn't fight the rest
// of the menu-bar look.
//
// Dots are drawn as actual Rectangles (not font glyphs) on purpose: a
// filled "●" and an outline "○" from the same font very rarely share the
// same visual ink size at an identical pixel size, which made the active/
// has-windows/empty states look inconsistently sized. A Rectangle with
// radius = width/2 guarantees every state is pixel-identical apart from
// the one property that's actually supposed to differ.
Row {
    id: root
    spacing: 10

    // Named/special workspaces (negative ids) are left out of the pill row;
    // this is only for the numbered 1..N workspaces you switch between daily.
    readonly property int workspaceCount: {
        let maxId = Settings.workspaceCount;
        for (const w of Hyprland.workspaces.values) {
            if (w.id > maxId)
                maxId = w.id;
        }
        return maxId;
    }

    Repeater {
        model: root.workspaceCount

        Item {
            required property int index
            readonly property int wsId: index + 1
            readonly property var ws: {
                for (const w of Hyprland.workspaces.values) {
                    if (w.id === wsId)
                        return w;
                }
                return null;
            }
            readonly property bool exists: ws !== null
            readonly property bool isActive: Hyprland.focusedWorkspace?.id === wsId
            readonly property bool hasWindows: exists && ws.toplevels.values.length > 0

            implicitWidth: 16
            implicitHeight: Appearance.barHeight - 8

            Rectangle {
                anchors.centerIn: parent
                readonly property int dotSize: parent.isActive ? 7 : 6
                width: dotSize
                height: dotSize
                radius: dotSize / 2
                color: parent.isActive ? Appearance.textPrimary
                       : (parent.hasWindows ? Appearance.textSecondary : "transparent")
                border.width: parent.isActive || parent.hasWindows ? 0 : 1
                border.color: Appearance.textDisabled

                Behavior on width {
                    NumberAnimation { duration: Appearance.animFast }
                }
                Behavior on height {
                    NumberAnimation { duration: Appearance.animFast }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: HyprDispatch.workspace(parent.wsId)
            }
        }
    }
}
