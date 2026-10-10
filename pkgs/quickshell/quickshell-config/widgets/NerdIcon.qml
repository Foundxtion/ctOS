import QtQuick

import "root:/config"

// A single icon glyph rendered from the Nerd Font. Keep icon rendering going
// through this component (instead of raw Text elsewhere) so font/size
// changes in Appearance.qml apply everywhere at once.
Text {
    id: root

    property color iconColor: Appearance.textPrimary
    property int size: Appearance.iconSize
    // Manual optical-centering correction, in px. Positive nudges the glyph
    // right, negative nudges it left. Some Nerd Font glyphs have asymmetric
    // side bearing baked into the font, and a fixed-size box centers the
    // box rather than the ink inside it. Only the Apple logo still comes
    // from a font at all, so this is rarely needed now — it stays for the
    // optional menu-row icons.
    property real hShift: 0

    text: ""
    color: iconColor
    font.family: Appearance.iconFontFamily
    font.pixelSize: size
    width: Math.round(size * 1.35)
    height: width
    leftPadding: hShift > 0 ? hShift : 0
    rightPadding: hShift < 0 ? -hShift : 0
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
        ColorAnimation { duration: Appearance.animFast }
    }
}
