import QtQuick

import "root:/config"
import "root:/services"
import "root:/widgets"
import "root:/widgets/icons"

// The Battery panel, built from the same pieces as the Wi-Fi and Bluetooth
// ones so all four read as one family: a title, a grouped block with the
// state in it, and a note underneath.
Column {
    id: root
    width: parent ? parent.width : 260
    spacing: Appearance.popupSpacing

    PanelTitle {
        width: root.width
        text: "Battery"
    }

    Rectangle {
        width: root.width
        implicitHeight: 62
        height: implicitHeight
        radius: 11
        color: Appearance.groupBackground

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            BatteryIcon {
                anchors.verticalCenter: parent.verticalCenter
                charge: Battery.percentInt / 100
                charging: Battery.charging
                low: Battery.isLow
                scaleFactor: 1.6
                color: Appearance.textPrimary
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    text: Battery.percentInt + "%"
                    color: Appearance.textPrimary
                    font.family: Appearance.fontFamily
                    font.pixelSize: 20
                    font.bold: true
                }

                Text {
                    text: {
                        if (Battery.charging)
                            return "Charging";
                        if (Battery.fullyCharged)
                            return "Fully Charged";
                        if (Battery.discharging)
                            return "On Battery";
                        return "";
                    }
                    color: Battery.charging ? Appearance.accentGreen : Appearance.textSecondary
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                }
            }
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            visible: Battery.timeRemainingLabel.length > 0
            text: Battery.timeRemainingLabel
            color: Appearance.textSecondary
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSizeSmall
            horizontalAlignment: Text.AlignRight
        }
    }

    Text {
        width: root.width
        visible: Battery.isLow && !Battery.charging
        text: "Low battery \u2014 consider plugging in."
        color: Appearance.accentRed
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeSmall
        wrapMode: Text.WordWrap
        leftPadding: 4
    }
}
