import QtQuick

import "root:/config"
import "root:/services"
import "root:/widgets"
import "root:/widgets/icons"

// The Wi-Fi status icon. Three states, matching what macOS shows:
//   * wired only        the network globe, because arcs would be a lie
//   * radio off         the Wi-Fi mark with a bar through it
//   * radio on          the mark with arcs lit to the current signal level
BarButton {
    id: root

    // Wired-only: connected over Ethernet with no Wi-Fi association. If both
    // are up, the Wi-Fi mark stays — that's the one with a strength worth
    // reporting.
    readonly property bool wiredOnly: Network.onEthernet && Network.connectedSsid === ""

    GlobeIcon {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.wiredOnly
        size: Appearance.iconSize
        color: Appearance.textPrimary
    }

    WifiIcon {
        anchors.verticalCenter: parent.verticalCenter
        visible: !root.wiredOnly
        size: Appearance.iconSize
        slashed: !Network.wifiEnabled
        // Not associated with anything yet: the mark is drawn hollow, all
        // three arcs dimmed, rather than showing a strength it doesn't have.
        level: Network.connectedSsid !== "" ? Network.signalLevel(Network.connectedSignal) : 0
        color: Network.wifiEnabled ? Appearance.textPrimary : Appearance.textDisabled
    }
}
