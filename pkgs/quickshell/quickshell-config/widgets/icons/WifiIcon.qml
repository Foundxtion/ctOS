import QtQuick
import QtQuick.Shapes

import "root:/config"

// The macOS Wi-Fi symbol, drawn as real geometry rather than a font glyph.
//
// Apple's mark is a dot with three concentric arcs radiating up from it,
// each arc sweeping 100 degrees, all sharing one center, with round caps.
// Signal strength is shown by dimming arcs from the outside in — the shape
// never changes size, only the ink density, which is why it stays legible
// at menu-bar size.
//
// Everything is laid out on a 16x16 design grid and scaled by `u`, so the
// proportions hold at any `size`.
Item {
    id: root

    property real size: Appearance.iconSize
    property color color: Appearance.textPrimary
    // How many of the three arcs are lit: 0 (dot only) .. 3 (full strength).
    property int level: 3
    // Draws the diagonal bar through the mark, for "Wi-Fi is off".
    property bool slashed: false
    // Opacity used for arcs above the current level.
    property real dimOpacity: 0.28

    implicitWidth: size
    implicitHeight: size

    readonly property real u: size / 16
    readonly property real cx: 8 * u
    readonly property real cy: 12.2 * u
    readonly property real stroke: 1.7 * u

    function tint(f: real): color {
        return Qt.rgba(root.color.r, root.color.g, root.color.b, root.color.a * f);
    }

    function arcAlpha(index: int): real {
        return root.level >= index ? 1.0 : root.dimOpacity;
    }

    Shape {
        anchors.fill: parent
        // Multisampled layer instead of Shape.CurveRenderer: the curve
        // renderer only exists from Qt 6.6 and silently changes name across
        // versions, while layer.samples has worked forever and gives the
        // same clean edges at this size.
        layer.enabled: true
        layer.samples: 4
        layer.smooth: true

        // ── Outer arc ────────────────────────────────────────────
        ShapePath {
            strokeColor: root.tint(root.arcAlpha(3))
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.cx
                centerY: root.cy
                radiusX: 8.4 * root.u
                radiusY: 8.4 * root.u
                startAngle: 220
                sweepAngle: 100
            }
        }

        // ── Middle arc ───────────────────────────────────────────
        ShapePath {
            strokeColor: root.tint(root.arcAlpha(2))
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.cx
                centerY: root.cy
                radiusX: 5.6 * root.u
                radiusY: 5.6 * root.u
                startAngle: 220
                sweepAngle: 100
            }
        }

        // ── Inner arc ────────────────────────────────────────────
        ShapePath {
            strokeColor: root.tint(root.arcAlpha(1))
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.cx
                centerY: root.cy
                radiusX: 2.8 * root.u
                radiusY: 2.8 * root.u
                startAngle: 220
                sweepAngle: 100
            }
        }

        // ── The dot ──────────────────────────────────────────────
        ShapePath {
            strokeColor: "transparent"
            fillColor: root.tint(1.0)

            PathAngleArc {
                centerX: root.cx
                centerY: root.cy
                radiusX: 1.2 * root.u
                radiusY: 1.2 * root.u
                startAngle: 0
                sweepAngle: 360
            }
        }

        // ── Off state ────────────────────────────────────────────
        ShapePath {
            strokeColor: root.slashed ? root.tint(1.0) : "transparent"
            strokeWidth: root.stroke
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            startX: 2.6 * root.u
            startY: 13.4 * root.u

            PathLine {
                x: 13.4 * root.u
                y: 2.6 * root.u
            }
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: Appearance.animFast }
    }
}
