#!/bin/bash

SCRIPTPATH="$(dirname "$0")"
CURRENT="$(pwd)"

cd $SCRIPTPATH
swift build -c release
cp -f .build/release/SwiftFrame /usr/local/bin/swiftframe
rm -r .build/release

echo "Installed swiftframe into /usr/locale/bin/swiftframe"

cd $CURRENT
