# This runs before a user audio server exists. Do not use PipeWire/PulseAudio's
# default PCM or change mixer volume or mute state just to play a boot sound.
touch /run/ctos-startup-chime/played

if [[ "$STARTUP_SOUND_DEVICE" == auto ]]; then
    mapfile -t devices < <(awk '
        /playback/ {
            split($1, id, "[-:]")
            device = "plughw:" (id[1] + 0) "," (id[2] + 0)
            if ($0 !~ /HDMI|DisplayPort/) print device
            else digital[++count] = device
        }
        END { for (i = 1; i <= count; i++) print digital[i] }
    ' /proc/asound/pcm)
else
    devices=("$STARTUP_SOUND_DEVICE")
fi

for device in "${devices[@]}"; do
    if timeout 4s aplay --quiet --nonblock --device "$device" "$STARTUP_SOUND_FILE"; then
        exit 0
    fi
done
echo "No available ALSA playback device for the startup chime; continuing boot."
