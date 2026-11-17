#!/usr/bin/env python3
"""Synthesize sentences with Kokoro. Runs in the Kokoro venv, not the Manim one.

Usage: ~/.venvs/kokoro/bin/python -I kokoro_say.py <voice> <speed> < jobs.json
jobs.json is a list of {"text": "...", "out": "/path/clip.wav"}. Writes 24 kHz mono 16-bit WAVs.
The model is loaded once per call. Model files: $KOKORO_DIR (default ~/.local/share/kokoro).
"""
import json
import os
import sys
import wave

import numpy as np
from kokoro_onnx import Kokoro

voice, speed = sys.argv[1], float(sys.argv[2])
d = os.path.expanduser(os.environ.get("KOKORO_DIR", "~/.local/share/kokoro"))
k = Kokoro(os.path.join(d, "kokoro-v1.0.onnx"), os.path.join(d, "voices-v1.0.bin"))
for job in json.load(sys.stdin):
    samples, sr = k.create(job["text"], voice=voice, speed=speed, lang="en-us")
    pcm = (np.clip(samples, -1, 1) * 32767).astype(np.int16)
    with wave.open(job["out"], "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(pcm.tobytes())
