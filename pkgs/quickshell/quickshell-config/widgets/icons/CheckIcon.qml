import QtQuick
import QtQuick.Shapes

import "root:/config"

// The checkmark macOS puts beside a selected menu row or the active
// output device. Two strokes, round caps, slightly steeper on the rise
// than the fall — same proportions as the system glyph.
Item {
    id: root

    property real size: Appearance.iconSize
    property color color: Appearance.textPrimary

    implicitWidth: size
    implicitHeight: size

    readonly property real u: size / 16

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        layer.smooth: true

        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.9 * root.u
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            startX: 3.2 * root.u
            startY: 8.6 * root.u

            PathLine { x: 6.4 * root.u;  y: 11.9 * root.u }
            PathLine { x: 12.9 * root.u; y: 4.3 * root.u }
        }
    }
}
