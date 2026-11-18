#!/bin/sh
# Render the app icon and the menu bar icon from the owl code into App/Assets.xcassets.
# Run after changing BrandIcons.swift (or the owl), then commit the PNGs.
set -e
cd "$(dirname "$0")/.."
assets="$PWD/App/Assets.xcassets"
swift run --package-path Packages/GazelingKit PoseSheet icons \
    "$assets/AppIcon.appiconset" "$assets/MenuBarIcon.imageset"
