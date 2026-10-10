import QtQuick

import "root:/config"

// The Control Center slider: a thick rounded track with a flush white fill
// and no protruding handle. macOS puts the relevant glyph *inside* the
// left end of the track, where it reads dark once the fill slides past it
// and light while it sits on the bare track — `iconOverFill` below exposes
// exactly that state so the caller can colour its own glyph accordingly.
Item {
    id: root

    property real from: 0
    property real to: 100
    property real value: 0
    property real thickness: 26
    property color fillColor: Appearance.sliderFill
    property color trackColor: Appearance.sliderTrack
    property bool enabled: true

    // Anything assigned as a child is centred in the left end of the track.
    default property alias iconContent: iconSlot.data

    signal moved(real value)

    implicitHeight: thickness
    implicitWidth: 200
    opacity: enabled ? 1.0 : 0.4

    readonly property real ratio: to > from
                                  ? Math.max(0, Math.min(1, (value - from) / (to - from)))
                                  : 0

    // True once the fill has slid far enough right to sit under the glyph.
    readonly property bool iconOverFill: fill.width > iconSlot.x + iconSlot.width * 0.5

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.trackColor

        Rectangle {
            id: fill
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            // Never render a sliver narrower than the pill's own corner
            // radius — it would clip into a lens shape instead of a pill.
            width: root.ratio <= 0 ? 0 : Math.max(track.height, track.width * root.ratio)
            radius: track.radius
            color: root.fillColor
        }

        Item {
            id: iconSlot
            x: Math.round(root.thickness * 0.16)
            width: Math.round(root.thickness * 0.62)
            height: width
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function setFromX(px: real): void {
            const r = Math.max(0, Math.min(1, px / width));
            const v = root.from + r * (root.to - root.from);
            root.value = v;
            root.moved(v);
        }

        onPressed: (mouseEv) => setFromX(mouseEv.x)
        onPositionChanged: (mouseEv) => { if (pressed) setFromX(mouseEv.x); }
    }
}
