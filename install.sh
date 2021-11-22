#!/bin/bash

set -e

SCRIPTPATH="$(dirname "$0")"

swift build -c release --package-path "$SCRIPTPATH" -v
install -v "$SCRIPTPATH/.build/release/swiftframe" "/usr/local/bin/swiftframe"

echo -e "[SUCCESS] Installed swiftframe into /usr/local/bin/swiftframe"
