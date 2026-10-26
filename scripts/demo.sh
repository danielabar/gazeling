#!/bin/sh
# Build, then start the app with short timers so a break appears within 30 seconds.
# Replaces any running copy. Timings are not saved to the user's settings.
set -e
cd "$(dirname "$0")/.."
scripts/build.sh
dir=$(xcodebuild -project Gazeling.xcodeproj -scheme Gazeling -showBuildSettings | awk '/ BUILT_PRODUCTS_DIR/{print $3}')
pkill -x Gazeling || true
sleep 1
open "$dir/Gazeling.app" --args --short-interval 30 --heads-up 10 --short-duration 20
