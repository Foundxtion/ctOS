import QtQuick

import "root:/config"
import "root:/widgets"

BarButton {
    id: root
    horizontalPadding: 11

    NerdIcon {
        anchors.verticalCenter: parent.verticalCenter
        text: Icons.apple
        size: 15
    }
}
