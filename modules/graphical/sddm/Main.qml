// SPDX-License-Identifier: GPL-3.0-or-later
// Adapted from Chili; Copyright 2018 Marian Arlt and 2016 David Edmundson.
import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import SddmComponents 2.0
import "components"

Rectangle {
    id: root
    // SDDM resizes this root to each display's actual logical dimensions.
    width: 1280
    height: 800
    color: "black"
    property string notificationMessage: ""
    property string generalFontColor: "white"
    property int generalFontSize: config.FontPointSize || Math.max(12, Math.min(20, height / 80))

    TextConstants { id: textConstants }
    Wallpaper { anchors.fill: parent; imageSource: config.background }

    RowLayout {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: root.generalFontSize * 1.5
        spacing: root.generalFontSize
        KeyboardLayoutButton { implicitWidth: 32; implicitHeight: 24 }
        Label {
            id: clockLabel
            color: root.generalFontColor
            font.pointSize: root.generalFontSize
            function updateTime() { text = new Date().toLocaleString(Qt.locale("en_US"), "ddd dd MMMM, hh:mm A") }
            Component.onCompleted: updateTime()
            Timer { interval: 1000; repeat: true; running: true; onTriggered: clockLabel.updateTime() }
        }
    }

    StackView {
        id: loginFormStack
        anchors.fill: parent
        anchors.bottomMargin: inputPanel.keyboardActive ? inputPanel.height : 0
        focus: true
        initialItem: LoginForm {
            id: userListComponent
            userListModel: userModel
            userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
            lastUserName: userModel.lastUser
            usernameFontSize: root.generalFontSize
            usernameFontColor: root.generalFontColor
            faceSize: config.AvatarPixelSize || Math.max(80, Math.min(128, root.height / 8))
            showUserList: userModel.count > 0
            notificationMessage: root.notificationMessage
            actionItems: [
                ActionButton {
                    iconSource: "assets/suspend.svgz"
                    text: config.translationSuspend || "Suspend"
                    onClicked: sddm.suspend()
                    enabled: sddm.canSuspend
                    iconSize: root.generalFontSize * 2
                },
                ActionButton {
                    iconSource: "assets/reboot.svgz"
                    text: config.translationReboot || textConstants.reboot
                    onClicked: sddm.reboot()
                    enabled: sddm.canReboot
                    iconSize: root.generalFontSize * 2
                },
                ActionButton {
                    iconSource: "assets/shutdown.svgz"
                    text: config.translationPowerOff || textConstants.shutdown
                    onClicked: sddm.powerOff()
                    enabled: sddm.canPowerOff
                    iconSize: root.generalFontSize * 2
                }
            ]
            onLoginRequest: {
                root.notificationMessage = ""
                sddm.login(username, password, sessionMenu.currentIndex)
            }
        }
    }

    Loader {
        id: inputPanel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        property bool keyboardActive: item ? item.active : false
        visible: keyboardActive
        source: "components/VirtualKeyboard.qml"
        function showHide() {
            if (!item) return
            item.activated = !item.activated
            if (item.activated) Qt.inputMethod.show()
            else Qt.inputMethod.hide()
        }
    }

    SessionMenu {
        id: sessionMenu
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: root.generalFontSize * 1.5
        rootFontSize: root.generalFontSize
        rootFontColor: root.generalFontColor
        visible: !inputPanel.keyboardActive
    }
    Connections {
        target: sddm
        onLoginFailed: {
            root.notificationMessage = textConstants.loginFailed
            notificationResetTimer.start()
        }
    }
    Timer { id: notificationResetTimer; interval: 3000; onTriggered: root.notificationMessage = "" }
}
