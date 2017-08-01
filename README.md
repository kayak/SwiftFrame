# SwiftFrame

SwiftFrame is a command line application for composing framed screenshots. Here's an example of a framed screenshot from the KAYAK iOS app.

![Framed Screenshot](https://github.com/kayak/SwiftFrame/blob/master/Example/Screenshots/iPhone5s%7Eframed.png)

## Usage

For the complete set of options please see

```
swiftframe -h
```

A working example is set up inside the `Example` folder.

## Building

The project includes a `build.sh` script for compiling the binary within the `Example` folder.

## Why not frameit?

Fastlane's [frameit](https://github.com/fastlane/fastlane/tree/master/frameit) is an awesome tool but we have, unfortunately, found it to be too limitting for our own needs. At the time of writing this, the following reasons drove us towards implementing a stand-alone solution:

- Long titles could not properly be forced onto more than one line in frameit. The font size just shrinks until the text fits onto a single line which usually produces small text and different font sizes for every screenshot.
- Due to the multitude of brands and locales that we support, we had to offload frameit to our build server since running it locally and on demand turned out to be too slow.
- The fact that frameit was built on top of imagemagick seemingly made it hard to easily address any of the above with a pull request.
