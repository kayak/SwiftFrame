# SwiftFrame

SwiftFrame is a command line application for composing and laying out screenshots. Here's an example from the sample app.

<img src="Example/ExampleScreenshot.png" alt="Framed Screenshot" width="250">

## Installation
### Directly
To build the project and install the tool, clone the repository and run the `install.sh` script. This will compile a binary and install it into `usr/local/bin/swiftframe`.
### [Mint](https://github.com/yonaskolb/mint)
```
$ mint install kayak/SwiftFrame
```

## Usage

To use SwiftFrame, you need to pass it a configuration file (which is a plain JSON file). The format of the file is specified as following (indent levels represent levels within the JSON):

* `stringsPath`: a path to a folder with `.strings` files, prefixed with the corresponding locale (e.g. `en.strings`)
* `maxFontSize`: the maximum font point size to use. SwiftFrame will be always try to render the text at the largest point size that fits within the bounding rectangle. If the determined point size is larger than `maxFontSize`, the latter will be used
* `outputPaths`: an array of paths to where SwiftFrame should output the finished screenshots. This is an array in case you want to render the files into multiple directories at the same time. (Note: screenshots will be placed into subfolders organised by locale within these paths)
* `fontFile`: a path to a font file
* `format`: the output format of the screenshots, can be `png`, `jpeg` or `jpg`
* `textColor`: a RGB color in Hex format (e.g. `#FFF`) to use for titles
* `outputWholeImage`: a boolean telling the application whether or not to also output the whole image instead of just the sliced up screenshots
* `clearDirectories`: a boolean telling the application whether or not to clear the specified output directories before writing new files to it. This prevents random screenshots from being used in case you update your template file to include one less screenshot for example
* `deviceData`: an array containing device specific data about screenshot and text coordinates (this way you can frame screenshots for more than one device per config file)
  * `outputSuffix`: a suffix to apply to the output files in addition to the locale identifier and index
  * `screenshots`: a folder path containing a subfolder for each locale, which in turn contains all the screenshots for that device
  * `templateFile`: an image file that will be rendered above the screenshots to overlay device frames (e.g. see `Example/Template Files/iPhone X/TemplateFile.png`) **Note:** places where screenshots should go need to be transparent
  * `screenshotData`: an array containing further information about screenshot coordinates
    * `screenshotName`: the file name (just name, not path) to the screenshot file to render
    * `zIndex`: **optional**, use this to avoid wrong rendering order if two screenshots need to overlap each other for example
    * `bottomLeft`, `bottomRight`, `topLeft` and `topRight`: the corners of the screenshot to render. Note that screenshots can be rotated in 3D, so the corners of the resulting don't have to form 90 degree angles
      * `x`: The x coordinate of the corner point, relative to the left edge
      * `y`: the y coordinate of the corner point, relative to the top or bottom edge, depending on `coordinatesOriginIsTopLeft`
  * `textData`: an array containing further information about text titles coordinates and its layout
    * `titleIdentifer`: the key that SwiftFrame should look for in the `.strings` file for a certain title
    * `textColorOverride`: **optional**, a color in Hex format to use specifically for this title
    * `textAlignment`: the text alignment in CSS style (`left`, `right`, `center`, `justify` or `natural`)
    * `customFontPath`: **optional**, a path to a font file to use specifically for this title
    * `groupIdentifier`: **optional**, an identifier for a text group (see below)
    * `topLeft` and `bottomRight`: the bounding coordinate points of the text (as of right now, it's not possible to have rotated text)
      * `x`: The x coordinate of the corner point, relative to the left edge
      * `y`: the y coordinate of the corner point, relative to the top or bottom edge, depending on `coordinatesOriginIsTopLeft` 
* `textGroups`: **optional**, an array of text groups which you can use to force multiple titles to use the same font size
  * `identifier`: the identifier of the text group
  * `maxFontSize`: the maximum font point size titles with this group ID should be using (overrides the global `maxFontSize`)

## Example

To run the example, either install the CLI (see above) and run `swiftframe -c Example/example.config --verbose` or directly via `swift run swiftframe -c Example/example.config --verbose`

## Why not frameit?

Fastlane's [frameit](https://github.com/fastlane/fastlane/tree/master/frameit) is an awesome tool but we have, unfortunately, found it to be too limitting for our own needs. At the time of writing this, the following reasons drove us towards implementing a stand-alone solution:

- No 3D placement of screenshots or support for multiple titles/screenshot in one framed image

- Long titles could not properly be forced onto more than one line in frameit. The font size just shrinks until the text fits onto a single line which usually produces small text and different font sizes for every screenshot.
- Due to the multitude of brands and locales that we support, we had to offload frameit to our build server since running it locally and on demand turned out to be too slow.
- The fact that frameit was built on top of imagemagick seemingly made it hard to easily address any of the above with a pull request.
