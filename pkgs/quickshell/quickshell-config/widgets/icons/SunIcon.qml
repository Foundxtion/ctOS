import QtQuick

import "root:/config"

// The brightness sun: a filled disc with eight rays. Built from plain
// Rectangles rather than a Shape — a ray is just a rounded bar rotated
// about the centre, and a disc is a Rectangle with radius = width / 2, so
// there is no curve geometry here worth the cost of a Shape.
//
// `level` interpolates between SF Symbols' sun.min and sun.max: at 0 the
// disc is small and the rays are stubs, at 1 the disc is full and the rays
// reach out. The rays always start at the same radius, so the icon grows
// outward from a fixed ring rather than sliding around, which keeps it
// steady while the value sweeps.
Item {
    id: root

    property real size: Appearance.iconSize
    property color color: Appearance.textPrimary

    // 0.0 .. 1.0
    property real level: 1.0

    implicitWidth: size
    implicitHeight: size

    readonly property real u: size / 16
    readonly property real clamped: Math.max(0, Math.min(1, level))

    readonly property real discRadius: (2.65 + 0.6 * clamped) * u
    readonly property real rayInner: 5.0 * u
    readonly property real rayLength: (1.15 + 1.35 * clamped) * u
    readonly property real rayWidth: 1.45 * u

    // Animating the input rather than each derived size keeps disc and rays
    // in step — they're all bindings off this one value.
    Behavior on level {
        NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.centerIn: parent
        width: root.discRadius * 2
        height: width
        radius: width / 2
        color: root.color
    }

    Repeater {
        model: 8

        Rectangle {
            required property int index

            width: root.rayWidth
            height: root.rayLength
            radius: width / 2
            color: root.color

            // Laid out pointing straight up, then spun into place.
            x: root.width / 2 - width / 2
            y: root.height / 2 - root.rayInner - root.rayLength

            // Origin is the icon's centre expressed in this bar's own
            // coordinates, so all eight land on one circle.
            transform: Rotation {
                origin.x: width / 2
                origin.y: root.rayInner + root.rayLength
                angle: index * 45
            }
        }
    }
}
