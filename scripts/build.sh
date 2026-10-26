#!/bin/sh
# Generate the Xcode project from project.yml, then build the app.
set -e
cd "$(dirname "$0")/.."
xcodegen generate
xcodebuild -project Gazeling.xcodeproj -scheme Gazeling -destination 'platform=macOS' build
