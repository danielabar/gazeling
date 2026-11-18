#!/usr/bin/env python3
"""Synthesize the break start and end chimes (a marimba-like wooden note pair) as WAV files.

Usage: python make_chimes.py <output-dir>
Writes chime-start.wav (rising) and chime-end.wav (falling). Original sound, no samples used.
"""
import sys
import wave

import numpy as np

SR = 24000
G5, C6 = 783.99, 1046.5


def marimba(f, dur=1.4, amp=0.6):
    t = np.arange(int(SR * dur)) / SR
    # Wooden bar: partials near 1 : 4 : 10, the upper ones dying faster.
    x = (
        np.sin(2 * np.pi * f * t) * np.exp(-t * 3.2)
        + 0.35 * np.sin(2 * np.pi * 4 * f * t) * np.exp(-t * 9)
        + 0.12 * np.sin(2 * np.pi * 10 * f * t) * np.exp(-t * 25)
    )
    return amp * x * np.minimum(t / 0.004, 1)


def sequence(notes, gap):
    tail = len(marimba(notes[0]))
    out = np.zeros(int(SR * gap * (len(notes) - 1)) + tail)
    for i, f in enumerate(notes):
        s = marimba(f)
        o = int(SR * gap * i)
        out[o : o + len(s)] += s
    return out / max(1.0, np.abs(out).max() / 0.7)


def save(path, x):
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes((np.clip(x, -1, 1) * 32767).astype(np.int16).tobytes())


out = sys.argv[1]
save(f"{out}/chime-start.wav", sequence([G5, C6], 0.16))
save(f"{out}/chime-end.wav", sequence([C6, G5], 0.16))
