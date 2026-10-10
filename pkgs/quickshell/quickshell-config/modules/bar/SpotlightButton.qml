import QtQuick

import "root:/config"
import "root:/services"
import "root:/widgets"

// A magnifying-glass icon, like the Spotlight icon on macOS's menu bar.
// Clicking it just runs your existing rofi command (see
// config/Settings.qml -> spotlightCommand) — it doesn't reimplement a
// launcher, it's a mouse-friendly trigger for the one you already have.
BarButton {
    id: root
    onClicked: PowerControl.openSpotlight()

    NerdIcon {
        anchors.verticalCenter: parent.verticalCenter
        text: Icons.search
        size: 13
    }
}
