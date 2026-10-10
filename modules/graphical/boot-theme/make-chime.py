#!/usr/bin/env python3
"""Synthesize an original, quiet major chord; no sampled recordings required."""
import math
import struct
import sys
import wave

RATE = 48000
DURATION = 2.8
NOTES = (130.8128, 196.0, 261.6256, 329.6276, 392.0, 523.2511)

with wave.open(sys.argv[1], "wb") as sound:
    sound.setnchannels(2)
    sound.setsampwidth(2)
    sound.setframerate(RATE)
    frames = bytearray()
    for frame in range(int(RATE * DURATION)):
        time = frame / RATE
        attack = 1.0 - math.exp(-time / 0.012)
        tail = min(1.0, (DURATION - time) / 0.25)
        envelope = attack * math.exp(-time / 0.85) * tail
        channels = []
        for detune in (0.9995, 1.0005):
            tone = sum(
                math.sin(2 * math.pi * note * detune * time)
                + 0.12 * math.sin(2 * math.pi * note * 2 * detune * time)
                for note in NOTES
            ) / len(NOTES)
            channels.append(round(32767 * 0.28 * envelope * tone))
        frames.extend(struct.pack("<hh", *channels))
    sound.writeframes(frames)
