import QtQuick
import QtQuick.Shapes

import "root:/config"

// The Bluetooth rune (Bjarkan, ᛒ), drawn as one continuous stroke — the
// same single-path construction Apple uses, so the crossings sit exactly on
// the stem instead of near it.
//
// The path walks: upper-left tip -> lower-right tip -> bottom of stem ->
// top of stem -> upper-right tip -> lower-left tip. Laid out on a 16x16
// grid and scaled by `u`.
Item {
    id: root

    property real size: Appearance.iconSize
    property color color: Appearance.textPrimary
    property bool slashed: false

    implicitWidth: size
    implicitHeight: size

    readonly property real u: size / 16
    readonly property real stroke: 1.55 * u

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        layer.smooth: true

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            startX: 5.0 * root.u
            startY: 6.0 * root.u

            PathLine { x: 11.0 * root.u; y: 10.0 * root.u }
            PathLine { x: 8.0 * root.u;  y: 13.2 * root.u }
            PathLine { x: 8.0 * root.u;  y: 2.8 * root.u }
            PathLine { x: 11.0 * root.u; y: 6.0 * root.u }
            PathLine { x: 5.0 * root.u;  y: 10.0 * root.u }
        }

        ShapePath {
            strokeColor: root.slashed ? root.color : "transparent"
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 2.6 * root.u
            startY: 13.4 * root.u

            PathLine { x: 13.4 * root.u; y: 2.6 * root.u }
        }
    }
}
