import QtQuick

import "root:/config"

// The round icon well that sits at the left of every Control Center list
// row. Filled with the system accent when whatever it represents is
// active — a connected network, a paired headset, the selected output —
// and a neutral translucent grey otherwise.
Rectangle {
    id: root

    property bool highlighted: false
    property color idleColor: Appearance.circleIdle
    property real diameter: Appearance.circleSize

    default property alias content: slot.data

    implicitWidth: diameter
    implicitHeight: diameter
    radius: width / 2
    color: highlighted ? Appearance.accent : idleColor

    Behavior on color {
        ColorAnimation { duration: Appearance.animNormal }
    }

    Item {
        id: slot
        anchors.fill: parent
    }
}
