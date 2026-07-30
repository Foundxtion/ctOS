import QtQuick

import "root:/config"
import "root:/services"
import "root:/widgets"

// The Apple menu. Grouped the way macOS groups it: sleep and the two
// restart-class actions together, session actions below, and the one
// Hyprland-specific entry kept apart at the bottom rather than mixed in
// with things that end your session.
//
// Every row is fire-and-forget — see services/PowerControl.qml for what
// each one actually runs.
Column {
    id: root
    width: parent ? parent.width : 220
    spacing: 0

    signal requestClose

    function run(fn: var): void {
        fn();
        root.requestClose();
    }

    MenuItem {
        width: root.width
        icon: Icons.moon
        label: "Sleep"
        onClicked: root.run(PowerControl.sleep)
    }

    MenuItem {
        width: root.width
        icon: Icons.restart
        label: "Restart\u2026"
        onClicked: root.run(PowerControl.restart)
    }

    MenuItem {
        width: root.width
        icon: Icons.power
        label: "Shut Down\u2026"
        onClicked: root.run(PowerControl.shutdown)
    }

    SectionDivider {}

    MenuItem {
        width: root.width
        icon: Icons.lock
        label: "Lock Screen"
        onClicked: root.run(PowerControl.lockScreen)
    }

    MenuItem {
        width: root.width
        icon: Icons.logout
        label: "Log Out\u2026"
        onClicked: root.run(PowerControl.logOut)
    }

    SectionDivider {}

    MenuItem {
        width: root.width
        icon: Icons.refresh
        label: "Reload Hyprland"
        onClicked: root.run(PowerControl.reloadHyprland)
    }
}
