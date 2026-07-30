import QtQuick

import "root:/config"
import "root:/services"
import "root:/widgets"
import "root:/widgets/icons"

// The Sound panel: output volume, where that output goes, input level, and
// where that input comes from — the same four things macOS's Control Center
// Sound module covers, in the same order.
//
// The device pickers appear whenever there is more than one device to pick
// from. With a single sound card there is nothing to choose, and macOS
// hides the list in that case too.
Column {
    id: root
    width: parent ? parent.width : 300
    spacing: Appearance.popupSpacing

    // Colour for a glyph sitting inside a slider: dark once the white fill
    // has slid underneath it, light while it's still over the bare track.
    function sliderGlyphColor(overFill: bool): color {
        return overFill ? Qt.rgba(0.12, 0.12, 0.13, 0.85) : Qt.rgba(1, 1, 1, 0.75);
    }

    PanelTitle {
        width: root.width
        text: "Sound"

        // The slider itself can only reach zero, which isn't the same thing
        // as muted — this keeps the distinction reachable, and reflects it.
        trailingContent: SpeakerIcon {
            size: 15
            muted: Audio.muted
            level: Audio.volumePercent < 50 ? 1 : 2
            color: Audio.muted ? Appearance.accentRed : Appearance.textSecondary

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: Audio.toggleMute()
            }
        }
    }

    // ── Output volume ─────────────────────────────────────────────
    StyledSlider {
        id: outputSlider
        width: root.width
        enabled: Audio.ready
        from: 0
        to: 100
        value: Audio.volumePercent
        onMoved: (v) => Audio.setVolumePercent(Math.round(v))

        SpeakerIcon {
            anchors.centerIn: parent
            size: parent.height
            muted: Audio.muted
            level: Audio.volumePercent === 0 ? 0 : (Audio.volumePercent < 50 ? 1 : 2)
            color: root.sliderGlyphColor(outputSlider.iconOverFill)
        }
    }

    // ── Output devices ────────────────────────────────────────────
    SectionHeader {
        text: "Output"
        visible: Audio.outputDevices.length > 1
    }

    Column {
        width: root.width
        spacing: 0
        visible: Audio.outputDevices.length > 1

        Repeater {
            model: Audio.outputDevices

            ListRow {
                id: outRow
                required property var modelData

                readonly property bool isCurrent: Audio.sink !== null && modelData.id === Audio.sink.id

                width: root.width
                title: Audio.deviceLabel(modelData)
                selected: isCurrent
                onClicked: Audio.setDefaultOutput(modelData)

                IconWell {
                    highlighted: outRow.isCurrent

                    SpeakerIcon {
                        anchors.centerIn: parent
                        size: 15
                        level: 1
                        color: outRow.isCurrent ? Appearance.textOnAccent : Appearance.textPrimary
                    }
                }

                trailingContent: CheckIcon {
                    visible: outRow.isCurrent
                    size: 13
                    color: Appearance.accent
                }
            }
        }
    }

    SectionDivider {
        spacing: 0
        visible: Audio.inputReady || Audio.inputDevices.length > 0
    }

    // ── Input level ───────────────────────────────────────────────
    Item {
        width: root.width
        height: 20
        visible: Audio.inputReady || Audio.inputDevices.length > 0

        SectionHeader {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Input"
        }

        MicrophoneIcon {
            id: inputMuteButton
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            size: 15
            muted: Audio.inputMuted
            color: Audio.inputMuted ? Appearance.accentRed : Appearance.textSecondary

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: Audio.toggleInputMute()
            }
        }
    }

    StyledSlider {
        id: inputSlider
        width: root.width
        visible: Audio.inputReady
        enabled: Audio.inputReady
        from: 0
        to: 100
        value: Audio.inputVolumePercent
        onMoved: (v) => Audio.setInputVolumePercent(Math.round(v))

        MicrophoneIcon {
            anchors.centerIn: parent
            size: parent.height
            muted: Audio.inputMuted
            color: root.sliderGlyphColor(inputSlider.iconOverFill)
        }
    }

    // ── Input devices ─────────────────────────────────────────────
    Column {
        width: root.width
        spacing: 0
        visible: Audio.inputDevices.length > 1

        Repeater {
            model: Audio.inputDevices

            ListRow {
                id: inRow
                required property var modelData

                readonly property bool isCurrent: Audio.source !== null && modelData.id === Audio.source.id

                width: root.width
                title: Audio.deviceLabel(modelData)
                selected: isCurrent
                onClicked: Audio.setDefaultInput(modelData)

                IconWell {
                    highlighted: inRow.isCurrent

                    MicrophoneIcon {
                        anchors.centerIn: parent
                        size: 15
                        color: inRow.isCurrent ? Appearance.textOnAccent : Appearance.textPrimary
                    }
                }

                trailingContent: CheckIcon {
                    visible: inRow.isCurrent
                    size: 13
                    color: Appearance.accent
                }
            }
        }
    }

    Text {
        width: root.width
        visible: Audio.inputDevices.length === 0
        text: "No input devices"
        color: Appearance.textSecondary
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeSmall
        leftPadding: 8
        bottomPadding: 4
    }
}
