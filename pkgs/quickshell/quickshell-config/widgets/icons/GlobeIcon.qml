import QtQuick
import QtQuick.Shapes

import "root:/config"

// The network globe — what macOS shows for a wired/Ethernet connection,
// where Wi-Fi would show its arcs. A circle, an equator, and a meridian
// ellipse, all stroke-only, on the usual 16x16 grid.
Item {
    id: root

    property real size: Appearance.iconSize
    property color color: Appearance.textPrimary

    implicitWidth: size
    implicitHeight: size

    readonly property real u: size / 16
    readonly property real stroke: 1.35 * u
    readonly property real r: 6.1 * u

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        layer.smooth: true

        // Outline
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.stroke
            fillColor: "transparent"

            PathAngleArc {
                centerX: 8 * root.u
                centerY: 8 * root.u
                radiusX: root.r
                radiusY: root.r
                startAngle: 0
                sweepAngle: 360
            }
        }

        // Equator
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 8 * root.u - root.r
            startY: 8 * root.u

            PathLine { x: 8 * root.u + root.r; y: 8 * root.u }
        }

        // Meridian — two half-arcs of a narrow ellipse, drawn top to bottom
        // and back, which closes into a full ellipse without needing a
        // PathMove between subpaths.
        ShapePath {
            strokeColor: root.color
            strokeWidth: root.stroke
            fillColor: "transparent"
            startX: 8 * root.u
            startY: 8 * root.u - root.r

            PathArc {
                x: 8 * root.u
                y: 8 * root.u + root.r
                radiusX: 3.1 * root.u
                radiusY: root.r
                direction: PathArc.Clockwise
            }
            PathArc {
                x: 8 * root.u
                y: 8 * root.u - root.r
                radiusX: 3.1 * root.u
                radiusY: root.r
                direction: PathArc.Clockwise
            }
        }
    }
}
