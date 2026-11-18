#!/bin/sh
# Build the Release app and package it for a GitHub Release.
#
# Used locally and by .github/workflows/release.yml, so both do the same thing.
#
# Output, in build/release/:
#   Gazeling.app
#   Gazeling-<version>.zip
#   Gazeling-<version>.zip.sha256
#
# Optional: set CURRENT_PROJECT_VERSION to override the build number
# (the workflow sets it to the run number).
set -e
cd "$(dirname "$0")/.."

version=$(sed -n 's/^ *MARKETING_VERSION: *"\(.*\)"/\1/p' project.yml)
if [ -z "$version" ]; then
    echo "Could not read MARKETING_VERSION from project.yml" >&2
    exit 1
fi

out=build/release
derived=build/DerivedData
rm -rf "$out" "$derived"
mkdir -p "$out"

xcodegen generate

# Universal binary (Apple silicon + Intel). Signing is ad hoc: set in project.yml.
build_number_arg=""
if [ -n "$CURRENT_PROJECT_VERSION" ]; then
    build_number_arg="CURRENT_PROJECT_VERSION=$CURRENT_PROJECT_VERSION"
fi
# shellcheck disable=SC2086
xcodebuild -project Gazeling.xcodeproj -scheme Gazeling -configuration Release \
    -destination 'generic/platform=macOS' -derivedDataPath "$derived" \
    ARCHS="arm64 x86_64" ONLY_ACTIVE_ARCH=NO $build_number_arg build

app="$derived/Build/Products/Release/Gazeling.app"
ditto "$app" "$out/Gazeling.app"

echo "Architectures: $(lipo -archs "$out/Gazeling.app/Contents/MacOS/Gazeling")"
lipo -archs "$out/Gazeling.app/Contents/MacOS/Gazeling" | grep -q arm64
lipo -archs "$out/Gazeling.app/Contents/MacOS/Gazeling" | grep -q x86_64
codesign --verify --deep --strict "$out/Gazeling.app"

# ditto keeps macOS metadata that plain zip can break.
zip="Gazeling-$version.zip"
ditto -c -k --keepParent "$out/Gazeling.app" "$out/$zip"
(cd "$out" && shasum -a 256 "$zip" > "$zip.sha256")

echo "Built $out/$zip"
cat "$out/$zip.sha256"
