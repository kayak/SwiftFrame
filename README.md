# SwiftFrame

SwiftFrame is a command line application for composing framed screenshots. Here's an example of a framed screenshot from the KAYAK iOS app.

![Framed Screenshot](https://github.com/kayak/SwiftFrame/blob/master/Example/Screenshots/iPhone5s%7Eframed.png)

## Usage

Configuration is mostly possible through command-line arguments (see `swiftframe -h` for further information). However, in most cases it's more convenient to provide a configuration file. The latter is a plain JSON file supporting the following options:

- `background` – How to fill the canvas background. Colors are expected to specified in hex format (CSS-shorthand notation supported). Possible settings:
  - Solid color in hex format, e.g. `"#FFFFFF"`
  - Linear gradient in CSS notation, e.g. `"linear-gradient(to right bottom, #000, #FFF)"`
- `titles` – Object detailing the rendering of titles. Child options:
  - `color` – Title color in hex format, e.g. `"#000"`
  - `font` – (Relative or absolute) path to a the font file
  - `padding` – Padding in pixels used to surround the title. Components separated by space in the order `"TOP LEFT BOTTOM RIGHT"`, e.g. `"5 10 5 10"`.
- `frames` – Object detailing the frames to be used. For every frame a key and an associated object are expected. The key is an escaped regular expression used for matching screenshot filenames, e.g. `".*iPhone5s\\.png"`. The object features the following optiojns:
  - `path` – (absolute or relative) path to the frame image file
  - `viewport` – The viewport coordinates in the frame's coordinate system given by the x and y components of the bottom left and top right corners, e.g. `"60 180 700 1316"`.
  - `padding` – Horizontal padding in pixels used to surround the frame
- `allowDownsampling` – Boolean indicating whether or not screenshots are allowed to be scaled down (retaining the aspect ratio) to fit the frame's viewport
- `outputSuffix` – Suffix appended when writing framed screenshots to the file system

A working example using a configurtion file is set up inside the `Example` folder.

## Building

The project includes a `build.sh` script for compiling the binary within the `Example` folder.

## Why not frameit?

Fastlane's [frameit](https://github.com/fastlane/fastlane/tree/master/frameit) is an awesome tool but we have, unfortunately, found it to be too limitting for our own needs. At the time of writing this, the following reasons drove us towards implementing a stand-alone solution:

- Long titles could not properly be forced onto more than one line in frameit. The font size just shrinks until the text fits onto a single line which usually produces small text and different font sizes for every screenshot.
- Due to the multitude of brands and locales that we support, we had to offload frameit to our build server since running it locally and on demand turned out to be too slow.
- The fact that frameit was built on top of imagemagick seemingly made it hard to easily address any of the above with a pull request.
