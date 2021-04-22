#!/bin/bash

set -e

SCRIPTPATH="$(dirname "$0")"

swift build -c release --package-path "$SCRIPTPATH" -v
install -v "$SCRIPTPATH/.build/release/swiftframe" "/usr/local/bin/swiftframe"

echo "|> \033[32mInstalled swiftframe into /usr/local/bin/swiftframe\033[0m"
