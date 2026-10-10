import QtQuick
import QtQuick.Effects

import "root:/config"

// A soft, wide drop shadow to sit behind a popup card.
//
// This works by blurring a hidden, solid black copy of the card's shape
// rather than by blurring the card itself — a MultiEffect draws its source,
// so effecting the real card would mean hiding it, and a hidden item stops
// receiving mouse input. A throwaway silhouette dodges that entirely.
// (ShaderEffectSource-backed effects render their source into a texture
// whether or not it is visible, which is what makes the trick work.)
//
// Loaded through a Loader with a string URL in PopupCard.qml, so if
// QtQuick.Effects is unavailable on a given Qt build the shadow simply
// never loads instead of taking the whole shell down with an import error.
Item {
    id: root

    property real cornerRadius: Appearance.popupRadius
    property real verticalOffset: Appearance.shadowOffset
    property real blurMax: Appearance.shadowBlurMax
    property real shadowOpacity: Appearance.shadowOpacity

    Item {
        id: silhouette
        anchors.fill: parent
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: root.cornerRadius
            color: "black"
        }
    }

    MultiEffect {
        anchors.fill: parent
        anchors.topMargin: root.verticalOffset
        anchors.bottomMargin: -root.verticalOffset
        source: silhouette
        blurEnabled: true
        blur: 1.0
        blurMax: root.blurMax
        opacity: root.shadowOpacity
    }
}
