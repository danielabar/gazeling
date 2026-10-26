#!/bin/sh
# Run the GazelingKit unit tests.
set -e
cd "$(dirname "$0")/.."
swift test --package-path Packages/GazelingKit
