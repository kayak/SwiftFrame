#!/bin/bash

dir=$(dirname "$0")
tmp_dir=$(mktemp -d)

function cleanup {
  rm -rvf "${tmp_dir}"
}

trap cleanup EXIT

output="${tmp_dir}/build/SwiftFrame.out"
xcodebuild -project "${dir}/SwiftFrame.xcodeproj" -scheme SwiftFrame archive -archivePath "${output}"
mv -v "${output}.xcarchive/Products/usr/local/bin/SwiftFrame" "${dir}/Example/swiftframe"
