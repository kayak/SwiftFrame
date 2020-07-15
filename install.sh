#!/bin/bash

set -e

SCRIPTPATH="$(dirname "$0")"

swift build -c release --package-path "$SCRIPTPATH"
cp -f "$SCRIPTPATH/.build/release/SwiftFrame" "/usr/local/bin/swiftframe"
rm -r "$SCRIPTPATH/.build/release"

echo "Installed swiftframe into /usr/local/bin/swiftframe"
