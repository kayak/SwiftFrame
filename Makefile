.PHONY: all

all:
	swift build -c release
	cp -f .build/release/SwiftFrame /usr/local/bin/swiftframe
	rm -r .build/release
	echo "Installed swiftframe into /usr/local/bin/swiftframe"
