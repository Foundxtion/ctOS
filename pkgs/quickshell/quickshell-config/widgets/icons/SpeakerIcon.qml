import QtQuick
import QtQuick.Shapes

import "root:/config"

// The macOS speaker mark: a filled cone-and-body silhouette with up to two
// sound waves arcing off it. Volume is shown by how many waves are drawn,
// and mute replaces them with a diagonal bar, matching SF Symbols'
// speaker / speaker.wave.1 / speaker.wave.2 / speaker.slash set.
Item {
    id: root

    property real size: Appearance.iconSize
    property color color: Appearance.textPrimary
    // 0 = silent body only, 1 = one wave, 2 = both waves.
    property int level: 2
    property bool muted: false

    implicitWidth: size
    implicitHeight: size

    readonly property real u: size / 16
    readonly property real stroke: 1.4 * u

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        layer.smooth: true

        // ── Speaker body (filled) ────────────────────────────────
        ShapePath {
            strokeColor: "transparent"
            fillColor: root.color
            joinStyle: ShapePath.RoundJoin
            startX: 1.8 * root.u
            startY: 6.1 * root.u

            PathLine { x: 4.6 * root.u; y: 6.1 * root.u }
            PathLine { x: 8.2 * root.u; y: 2.6 * root.u }
            PathLine { x: 8.2 * root.u; y: 13.4 * root.u }
            PathLine { x: 4.6 * root.u; y: 9.9 * root.u }
            PathLine { x: 1.8 * root.u; y: 9.9 * root.u }
            PathLine { x: 1.8 * root.u; y: 6.1 * root.u }
        }

        // ── Inner wave ───────────────────────────────────────────
        ShapePath {
            strokeColor: (!root.muted && root.level >= 1) ? root.color : "transparent"
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 8.4 * root.u
                centerY: 8.0 * root.u
                radiusX: 2.6 * root.u
                radiusY: 2.6 * root.u
                startAngle: -52
                sweepAngle: 104
            }
        }

        // ── Outer wave ───────────────────────────────────────────
        ShapePath {
            strokeColor: (!root.muted && root.level >= 2) ? root.color : "transparent"
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 8.4 * root.u
                centerY: 8.0 * root.u
                radiusX: 4.7 * root.u
                radiusY: 4.7 * root.u
                startAngle: -52
                sweepAngle: 104
            }
        }

        // ── Mute bar ─────────────────────────────────────────────
        ShapePath {
            strokeColor: root.muted ? root.color : "transparent"
            strokeWidth: root.stroke * 1.1
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 10.2 * root.u
            startY: 5.4 * root.u

            PathLine { x: 14.4 * root.u; y: 10.6 * root.u }
        }
    }
}
