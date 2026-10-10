import QtQuick
import QtQuick.Shapes

import "root:/config"

// A microphone, used to head the Input section of the Sound panel — the
// capsule body is a Rectangle, the cradle below it is a half-arc plus a
// short stem.
Item {
    id: root

    property real size: Appearance.iconSize
    property color color: Appearance.textPrimary
    property bool muted: false

    implicitWidth: size
    implicitHeight: size

    readonly property real u: size / 16

    Rectangle {
        x: 6.1 * root.u
        y: 2.2 * root.u
        width: 3.8 * root.u
        height: 7.6 * root.u
        radius: width / 2
        color: root.color
    }

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        layer.smooth: true

        // Cradle
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.35 * root.u
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 8 * root.u
                centerY: 8.1 * root.u
                radiusX: 3.7 * root.u
                radiusY: 3.7 * root.u
                startAngle: 0
                sweepAngle: 180
            }
        }

        // Stem
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.35 * root.u
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 8 * root.u
            startY: 11.8 * root.u

            PathLine { x: 8 * root.u; y: 13.8 * root.u }
        }

        // Mute bar
        ShapePath {
            strokeColor: root.muted ? root.color : "transparent"
            strokeWidth: 1.5 * root.u
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 2.8 * root.u
            startY: 13.2 * root.u

            PathLine { x: 13.2 * root.u; y: 2.8 * root.u }
        }
    }
}
