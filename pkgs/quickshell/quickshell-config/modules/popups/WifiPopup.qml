import QtQuick
import QtQuick.Controls

import "root:/config"
import "root:/services"
import "root:/widgets"
import "root:/widgets/icons"

// The Wi-Fi panel, laid out like a Control Center module: title and switch,
// then a grouped block describing the connection you actually have, then
// the list of networks you could have instead.
//
// The grouped block is the part macOS doesn't give you — it answers "what
// am I connected through, what address did I get, and what is it doing
// right now" without opening Network Settings. Every connected interface
// gets a row, so a machine on both wired and wireless shows both, with the
// one traffic is actually routed over marked as primary.
Column {
    id: root
    width: parent ? parent.width : 320
    spacing: Appearance.popupSpacing

    // Bound by Bar.qml to whether this panel is on screen. Wired to the
    // Network service's monitor count so throughput samples every second
    // while you're looking at it and idles back down when you aren't.
    property bool active: false

    // SSID currently expanded for password entry, or "" if none.
    property string pendingSsid: ""

    readonly property var connectedInterfaces: Network.interfaces.filter(i => i.connected)

    onActiveChanged: {
        if (active) {
            pendingSsid = "";
            Network.addMonitor();
            Network.refreshStatus();
            Network.scan();
        } else {
            Network.removeMonitor();
        }
    }

    Component.onCompleted: Network.refreshStatus()

    // nmcli reports addresses in CIDR form; the prefix length is noise in a
    // status line, so it's trimmed for display.
    function bareAddress(cidr: string): string {
        const slash = cidr.indexOf("/");
        return slash === -1 ? cidr : cidr.substring(0, slash);
    }

    function interfaceTitle(iface: var): string {
        if (iface.type === "ethernet")
            return "Ethernet";
        if (iface.type === "wifi")
            return iface.connection.length > 0 ? iface.connection : "Wi-Fi";
        return iface.connection.length > 0 ? iface.connection : iface.type;
    }

    // ── Header ────────────────────────────────────────────────────
    PanelTitle {
        width: root.width
        text: "Wi-Fi"

        trailingContent: ToggleSwitch {
            checked: Network.wifiEnabled
            onToggled: Network.toggleWifi()
        }
    }

    // ── Connection summary ────────────────────────────────────────
    Rectangle {
        width: root.width
        implicitHeight: summaryColumn.implicitHeight + 8
        height: implicitHeight
        radius: 11
        color: Appearance.groupBackground

        Column {
            id: summaryColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 4
            spacing: 0

            Repeater {
                model: root.connectedInterfaces

                ListRow {
                    id: ifaceRow
                    required property var modelData

                    width: summaryColumn.width
                    interactive: false
                    selected: Network.primary !== null && Network.primary.device === modelData.device
                    title: root.interfaceTitle(modelData)
                    subtitle: modelData.device
                              + " \u00b7 "
                              + (modelData.ip4.length > 0
                                 ? root.bareAddress(modelData.ip4)
                                 : "No IP address")

                    IconWell {
                        highlighted: true

                        GlobeIcon {
                            anchors.centerIn: parent
                            visible: ifaceRow.modelData.type !== "wifi"
                            size: 15
                            color: Appearance.textOnAccent
                        }

                        WifiIcon {
                            anchors.centerIn: parent
                            visible: ifaceRow.modelData.type === "wifi"
                            size: 15
                            level: Network.signalLevel(Network.connectedSignal)
                            color: Appearance.textOnAccent
                        }
                    }

                    trailingContent: Text {
                        visible: ifaceRow.modelData.type === "wifi"
                        text: "Disconnect"
                        color: disconnectMouse.containsMouse
                               ? Qt.lighter(Appearance.accent, 1.2)
                               : Appearance.accent
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSizeSmall
                        font.weight: Font.DemiBold

                        MouseArea {
                            id: disconnectMouse
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Network.disconnectDevice(ifaceRow.modelData.device)
                        }
                    }
                }
            }

            // Nothing is up at all.
            ListRow {
                visible: root.connectedInterfaces.length === 0
                width: summaryColumn.width
                interactive: false
                title: "Not Connected"
                subtitle: Network.wifiEnabled ? "Choose a network below" : "Wi-Fi is off"

                IconWell {
                    highlighted: false

                    WifiIcon {
                        anchors.centerIn: parent
                        size: 15
                        level: 0
                        slashed: !Network.wifiEnabled
                        color: Appearance.textSecondary
                    }
                }
            }

            // ── Live throughput ───────────────────────────────────
            // Sampled from the kernel's byte counters and differenced over
            // the sampling window, so this is a real instantaneous rate on
            // the primary interface, not a session average.
            Item {
                width: summaryColumn.width
                height: 40
                visible: Network.primary !== null

                Item {
                    id: rateRow
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    height: childrenRect.height

                    Column {
                        anchors.left: parent.left
                        width: rateRow.width / 2
                        spacing: 1

                        Text {
                            text: "\u2193  Download"
                            color: Appearance.textSecondary
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                        }

                        Text {
                            text: Network.formatRate(Network.rxRate)
                            color: Appearance.textPrimary
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeNormal
                            font.weight: Font.DemiBold
                        }
                    }

                    Column {
                        anchors.right: parent.right
                        width: rateRow.width / 2
                        spacing: 1

                        Text {
                            text: "\u2191  Upload"
                            color: Appearance.textSecondary
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                        }

                        Text {
                            text: Network.formatRate(Network.txRate)
                            color: Appearance.textPrimary
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeNormal
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }
        }
    }

    SectionDivider {
        spacing: 0
        visible: Network.wifiEnabled
    }

    SectionHeader {
        text: Network.scanning ? "Networks\u2026" : "Networks"
        visible: Network.wifiEnabled
    }

    // ── Network list ──────────────────────────────────────────────
    // Capped and scrollable: a busy apartment block can turn up thirty
    // access points, and a dropdown that runs off the bottom of the screen
    // is worse than one you have to scroll.
    Item {
        id: listBox
        width: root.width
        height: Math.min(listColumn.implicitHeight, 250)
        visible: Network.wifiEnabled

        Flickable {
            anchors.fill: parent
            contentHeight: listColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: listColumn
                width: listBox.width
                spacing: 0

                Repeater {
                    model: Network.networks

                    Column {
                        id: netEntry
                        required property var modelData
                        width: listColumn.width
                        spacing: 0

                        ListRow {
                            width: netEntry.width
                            title: netEntry.modelData.ssid
                            selected: netEntry.modelData.active
                            subtitle: netEntry.modelData.active ? "Connected" : ""

                            IconWell {
                                highlighted: netEntry.modelData.active

                                WifiIcon {
                                    anchors.centerIn: parent
                                    size: 15
                                    level: Network.signalLevel(netEntry.modelData.signal)
                                    color: netEntry.modelData.active
                                           ? Appearance.textOnAccent
                                           : Appearance.textPrimary
                                }
                            }

                            trailingContent: LockIcon {
                                visible: netEntry.modelData.secured
                                size: 13
                                color: Appearance.textSecondary
                            }

                            onClicked: {
                                if (netEntry.modelData.active)
                                    return;
                                if (netEntry.modelData.secured) {
                                    root.pendingSsid = (root.pendingSsid === netEntry.modelData.ssid)
                                        ? "" : netEntry.modelData.ssid;
                                } else {
                                    Network.connectTo(netEntry.modelData.ssid, "");
                                }
                            }
                        }

                        // Inline password entry, expanding under a locked
                        // network rather than in a separate dialog.
                        Item {
                            id: pwRow
                            visible: root.pendingSsid === netEntry.modelData.ssid
                            width: netEntry.width
                            height: visible ? 40 : 0

                            onVisibleChanged: if (visible) pwField.forceActiveFocus()

                            TextField {
                                id: pwField
                                anchors.left: parent.left
                                anchors.right: joinBtn.left
                                anchors.leftMargin: 8
                                anchors.rightMargin: 6
                                anchors.verticalCenter: parent.verticalCenter
                                height: 28
                                placeholderText: "Password"
                                echoMode: TextInput.Password
                                color: Appearance.textPrimary
                                placeholderTextColor: Appearance.textDisabled
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSizeNormal
                                leftPadding: 9
                                rightPadding: 9
                                topPadding: 0
                                bottomPadding: 0
                                verticalAlignment: TextInput.AlignVCenter

                                background: Rectangle {
                                    radius: 7
                                    color: Appearance.fieldBackground
                                    border.width: 1
                                    border.color: pwField.activeFocus
                                                  ? Appearance.accent
                                                  : Appearance.popupBorder
                                }

                                onAccepted: {
                                    Network.connectTo(netEntry.modelData.ssid, text);
                                    root.pendingSsid = "";
                                }
                            }

                            Rectangle {
                                id: joinBtn
                                anchors.right: parent.right
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                width: 52
                                height: 28
                                radius: 7
                                color: joinMouse.containsMouse
                                       ? Qt.lighter(Appearance.accent, 1.15)
                                       : Appearance.accent

                                Text {
                                    anchors.centerIn: parent
                                    text: "Join"
                                    color: Appearance.textOnAccent
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: Appearance.fontSizeNormal
                                }

                                MouseArea {
                                    id: joinMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Network.connectTo(netEntry.modelData.ssid, pwField.text);
                                        root.pendingSsid = "";
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: Network.networks.length === 0
                    text: Network.scanning ? "Looking for networks\u2026" : "No networks found"
                    color: Appearance.textSecondary
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                    leftPadding: 8
                    topPadding: 6
                    bottomPadding: 6
                }
            }
        }
    }
}
