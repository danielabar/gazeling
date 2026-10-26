#!/bin/sh
# Build the app, then launch it.
set -e
cd "$(dirname "$0")/.."
scripts/build.sh
dir=$(xcodebuild -project Gazeling.xcodeproj -scheme Gazeling -showBuildSettings | awk '/ BUILT_PRODUCTS_DIR/{print $3}')
open "$dir/Gazeling.app"
