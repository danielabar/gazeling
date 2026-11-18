#!/bin/sh
# Regenerate the bundled audio: one voice clip per exercise (Kokoro) and the two chimes.
# Output: Packages/GazelingKit/Sources/GazelingKit/Resources/Audio/*.m4a
#
# Needs a Python with kokoro-onnx and numpy, and the Kokoro model files. Defaults:
#   KOKORO_PYTHON=~/.venvs/kokoro/bin/python   KOKORO_DIR=~/.local/share/kokoro
# Also needs afconvert, which ships with macOS. See docs/development.md.
set -e
cd "$(dirname "$0")/.."
PY="${KOKORO_PYTHON:-$HOME/.venvs/kokoro/bin/python}"
VOICE="${GAZELING_VOICE:-af_heart}"
SPEED="${GAZELING_VOICE_SPEED:-0.95}"
OUT=Packages/GazelingKit/Sources/GazelingKit/Resources/Audio
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$OUT"

# Voice clips: <exercise-id>.en.m4a
"$PY" -I -c '
import json, sys
work = sys.argv[1]
scripts = json.load(open("scripts/audio/voice-scripts.json"))
json.dump([{"text": t, "out": f"{work}/{i}.en.wav"} for i, t in scripts.items()], sys.stdout)
' "$WORK" | "$PY" -I scripts/audio/kokoro_say.py "$VOICE" "$SPEED"

# Chimes: break-start.m4a, break-end.m4a
"$PY" -I scripts/audio/make_chimes.py "$WORK"
mv "$WORK/chime-start.wav" "$WORK/break-start.wav"
mv "$WORK/chime-end.wav" "$WORK/break-end.wav"

for wav in "$WORK"/*.wav; do
    name="$(basename "$wav" .wav)"
    afconvert -f m4af -d aac -b 64000 "$wav" "$OUT/$name.m4a"
done
ls -l "$OUT"
