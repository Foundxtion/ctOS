import QtQuick
import QtQuick.Shapes

import "root:/config"

// A small padlock, shown on secured networks. The body is a plain rounded
// Rectangle (crisper than a stroked path at this size) and only the
// shackle needs real curve geometry.
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

        // Shackle: a half-circle opening downward.
        ShapePath {
            strokeColor: root.color
            strokeWidth: 1.4 * root.u
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: 8 * root.u
                centerY: 7.0 * root.u
                radiusX: 2.6 * root.u
                radiusY: 2.6 * root.u
                startAngle: 180
                sweepAngle: 180
            }
        }
    }

    Rectangle {
        x: 3.7 * root.u
        y: 6.9 * root.u
        width: 8.6 * root.u
        height: 6.6 * root.u
        radius: 1.7 * root.u
        color: root.color
    }
}
