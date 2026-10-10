# This runs before a user audio server exists. Do not use PipeWire/PulseAudio's
# default PCM or change mixer volume or mute state just to play a boot sound.
# A GPU's HDMI PCM often appears before the laptop speaker codec. Re-enumerate
# during a bounded wait; a successful write to HDMI does not mean audible sound.
# This service is Type=exec, so waiting here does not hold up the greeter.
# The splash keeps its logo hidden until this cue, so that it appears as the
# chime starts. Send it on every way out, or the logo would stay hidden.
cued=
cue_splash() {
    if [[ -n "$cued" ]]; then return; fi
    cued=1
    plymouth update --status=ctos:chime 2>/dev/null || true
}
trap cue_splash EXIT

deadline=$((SECONDS + 5))
while ((SECONDS < deadline)); do
    if [[ "$STARTUP_SOUND_DEVICE" == auto ]]; then
        mapfile -t devices < <(awk '
            /playback/ && !/HDMI|DisplayPort/ {
                split($1, id, "[-:]")
                print (id[1] + 0) "," (id[2] + 0)
            }
        ' /proc/asound/pcm 2>/dev/null)
    else
        devices=("$STARTUP_SOUND_DEVICE")
    fi

    for device in "${devices[@]}"; do
        if ((SECONDS >= deadline)); then break; fi
        if [[ "$STARTUP_SOUND_DEVICE" == auto ]]; then
            card=${device%,*}
            pcm=${device#*,}
            # Wait for this card's mixer restore rule as well as its PCM node,
            # without waiting for unrelated udev events across the whole system.
            if ! udevadm wait --timeout=1 --initialized=yes \
                "/dev/snd/controlC${card}" "/dev/snd/pcmC${card}D${pcm}p"; then
                continue
            fi
            device="plughw:$device"
        fi

        echo "Playing startup chime on $device."
        cue_splash
        if timeout 6s aplay --quiet --nonblock --device "$device" "$STARTUP_SOUND_FILE"; then
            touch /run/ctos-startup-chime/played
            exit 0
        fi
    done
    sleep 0.1
done
echo "No available ALSA playback device for the startup chime; continuing boot."
