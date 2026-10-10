import QtQuick

import "root:/config"
import "root:/services"
import "root:/widgets"
import "root:/widgets/icons"

// Volume, drawn with the wave count tracking the actual level the way the
// macOS menu bar does — silent, one wave, two waves, or the mute bar.
BarButton {
    id: root

    SpeakerIcon {
        anchors.verticalCenter: parent.verticalCenter
        size: Appearance.iconSize
        muted: Audio.muted
        level: {
            if (Audio.volumePercent === 0)
                return 0;
            return Audio.volumePercent < 50 ? 1 : 2;
        }
        color: Audio.muted ? Appearance.textDisabled : Appearance.textPrimary
    }
}
