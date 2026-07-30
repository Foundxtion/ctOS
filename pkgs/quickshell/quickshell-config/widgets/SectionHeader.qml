import QtQuick

import "root:/config"

// The small dim caption macOS puts above a group inside a Control Center
// panel ("Output", "Input", "My Devices"). Title case, not all-caps —
// Apple moved away from all-caps section headers years ago.
Text {
    id: root

    property int inset: 7

    color: Appearance.textSecondary
    font.family: Appearance.fontFamily
    font.pixelSize: Appearance.fontSizeSmall
    font.weight: Font.DemiBold
    leftPadding: inset
    topPadding: 2
    bottomPadding: 1
}
