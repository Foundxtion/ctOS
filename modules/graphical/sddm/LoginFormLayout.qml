// SPDX-License-Identifier: GPL-3.0-or-later
// Adapted from Chili; Copyright 2018 Marian Arlt and 2016 David Edmundson.
import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Item {
    id: root
    property alias userListModel: userListView.model
    property alias actionItems: actionItemsLayout.children
    property alias notificationMessage: notificationsLabel.text
    property alias faceSize: userListView.avatarSize
    property alias usernameFontSize: userListView.rootFontSize
    property alias usernameFontColor: userListView.rootFontColor
    property bool showUserList: true
    property alias userList: userListView
    property alias userListCurrentIndex: userListView.currentIndex
    property var userListCurrentModelData: userListView.currentItem === null ? [] : userListView.currentItem.m
    default property alias _children: innerLayout.children
    property alias loginGroup: loginGroup

    // Center the entire avatar/name/password group, independently of the
    // header, power buttons, notifications and session selector.
    Column {
        id: loginGroup
        width: parent.width
        anchors.centerIn: parent
        spacing: root.usernameFontSize
        UserList {
            id: userListView
            width: parent.width
            height: implicitHeight
            visible: root.showUserList
        }
        ColumnLayout {
            id: innerLayout
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label {
            id: notificationsLabel
            anchors.horizontalCenter: parent.horizontalCenter
            visible: text.length > 0
            color: root.usernameFontColor
            font.italic: true
            font.pointSize: root.usernameFontSize
        }
    }
    RowLayout {
        id: actionItemsLayout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.usernameFontSize * 3
        spacing: root.usernameFontSize * 2
    }
}
