#!/bin/sh
# Build, then start the app with short timers so a break appears within 30 seconds.
# `scripts/demo.sh inspect` starts it with no automatic breaks instead, so the debug menu is the only
# way to start one. Replaces any running copy. Timings are not saved to the user's settings.
set -e
cd "$(dirname "$0")/.."
scripts/build.sh
dir=$(xcodebuild -project Gazeling.xcodeproj -scheme Gazeling -showBuildSettings | awk '/ BUILT_PRODUCTS_DIR/{print $3}')
pkill -x Gazeling || true
sleep 1
if [ "$1" = "inspect" ]; then
    open "$dir/Gazeling.app" --args --no-auto-breaks
else
    open "$dir/Gazeling.app" --args --short-interval 30 --heads-up 10 --short-duration 20
fi
