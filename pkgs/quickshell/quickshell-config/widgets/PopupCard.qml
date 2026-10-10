import QtQuick
import Quickshell

import "root:/config"

// A dropdown anchored below a bar item. It renders in one of the two shapes
// macOS actually uses:
//
//   menuStyle: true   the Apple menu — 10px radius, 5px padding, rows that
//                     run nearly edge to edge and highlight accent blue.
//   menuStyle: false  a Control Center panel — 16px radius, roomy padding,
//                     grouped sections and sliders.
//
// Dismissal on outside-click uses PopupWindow's own grabFocus (a real
// xdg_popup protocol grab) rather than HyprlandFocusGrab. HyprlandFocusGrab
// is a separate, Hyprland-specific mechanism explicitly meant for a
// different job — observing outside clicks *without* auto-closing — and
// mixing the two risks them fighting over the same grab.
//
// Because grabFocus drives `visible` itself (setting it false on outside
// click), `visible` can't also be externally data-bound here — QML drops
// an external binding the instant something else assigns the property
// directly, which would silently break re-opening. So the caller binds
// `shown` instead, and this component translates that into `visible`
// one-way, then reports back via `dismissed` when grabFocus closes it out
// from under `shown`.
//
// ── A note on the shadow margin ──────────────────────────────────────
// A blurred shadow needs to spill outside the card, and a popup window
// clips to its own bounds, so the window is deliberately built larger than
// the card by shadowMargin on every side. That transparent padding would
// throw the card off-position by exactly that margin, so anchor.rect is
// grown to compensate: the anchor rectangle is stretched by shadowMargin on
// whichever side the popup grows from, which pushes the window out by the
// same amount the card is inset. Set Appearance.shadowEnabled to false to
// collapse all of this back to flush, zero-margin anchoring.
PopupWindow {
    id: root

    // The bar item (a BarButton, typically) this popup drops down from.
    required property Item anchorItem

    // Bind this from the caller, e.g. shown: barWindow.openPopup === "wifi".
    // Do NOT bind visible directly — see note above.
    property bool shown: false

    // "left"  -> popup's left edge lines up with the anchor, grows right+down
    // "right" -> popup's right edge lines up with the anchor, grows left+down
    property string alignment: "right"

    property int cardWidth: 300
    property bool menuStyle: false

    readonly property int shadowMargin: Appearance.shadowEnabled ? Appearance.shadowMargin : 0
    readonly property int cardRadius: menuStyle ? Appearance.menuRadius : Appearance.popupRadius
    readonly property int cardPadding: menuStyle ? Appearance.menuPadding : Appearance.popupPadding

    default property alias content: column.data

    signal dismissed

    implicitWidth: cardWidth + shadowMargin * 2
    implicitHeight: column.implicitHeight + cardPadding * 2 + shadowMargin * 2
    color: "transparent"
    grabFocus: true

    anchor.item: anchorItem
    anchor.rect: Qt.rect(
        root.alignment === "left" ? -root.shadowMargin : 0,
        0,
        (root.anchorItem ? root.anchorItem.width : 0) + root.shadowMargin,
        (root.anchorItem ? root.anchorItem.height : 0) + Appearance.popupGap - root.shadowMargin)
    anchor.edges: (alignment === "left" ? Edges.Left : Edges.Right) | Edges.Bottom
    anchor.gravity: (alignment === "left" ? Edges.Right : Edges.Left) | Edges.Bottom

    onShownChanged: {
        if (visible !== shown)
            visible = shown;
    }
    onVisibleChanged: {
        // Still shown as far as the caller's state goes, but no longer
        // visible — that only happens when grabFocus closed us out from
        // under an outside click (or Escape). Tell the caller so it can
        // reset its own state to match.
        if (!visible && shown)
            dismissed();
    }

    Loader {
        // String URL, not a type reference, so QtQuick.Effects is only
        // resolved when the shadow is actually switched on.
        source: "root:/widgets/SoftShadow.qml"
        active: Appearance.shadowEnabled
        x: card.x
        y: card.y
        width: card.width
        height: card.height
        z: -1
        onLoaded: item.cornerRadius = Qt.binding(() => card.radius)
    }

    Rectangle {
        id: card

        x: root.shadowMargin
        y: root.shadowMargin
        width: root.cardWidth
        // Tracks the window's own animated height so the card and the
        // surface it lives on always resize together.
        height: root.implicitHeight - root.shadowMargin * 2

        radius: root.cardRadius
        color: root.menuStyle ? Appearance.menuBackground : Appearance.popupBackground
        border.width: 1
        border.color: Appearance.popupBorder

        // macOS dropdowns fade up into place over about a tenth of a
        // second. Only the appearance is animated — dismissal destroys the
        // window immediately, as it does on macOS.
        opacity: root.shown ? 1 : 0
        transform: Translate {
            y: root.shown ? 0 : -Appearance.popupGap

            Behavior on y {
                NumberAnimation { duration: Appearance.animPopup; easing.type: Easing.OutCubic }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: Appearance.animPopup }
        }

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: root.cardPadding
            spacing: root.menuStyle ? 0 : Appearance.popupSpacing
        }
    }

    Behavior on implicitHeight {
        NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic }
    }
}
