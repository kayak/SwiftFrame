import AppKit
import CoreGraphics
import Foundation

do {
    let options = CommandLineOptions()
    try options.parse(arguments: CommandLine.arguments)

    guard !options.help.isSpecified else {
        print(options.summarizeUsage())
        exit(0)
    }

    guard let configPath = options.configPath.arguments.first else {
        throw NSError(description: "Please specify a config file path")
    }
    let configURL = URL(fileURLWithPath: configPath)
    let data = try Data(contentsOf: configURL)
    let config = try JSONDecoder().decode(ConfigFile.self, from: data)

    if config.verbose {
        config.printSummary()
    }

//    for (frame, screenshots) in config.screenshotPathsByFrame {
//        let imageLoader = ImageLoader()
//        let composer = ImageComposer()
//        let writer = ImageWriter()
//
//        let adaptedTitleFont = try composer.adapt(
//            titleFont: config.titleFont,
//            toFitTitleTexts: config.titleTexts,
//            titlePadding: config.titlePadding,
//            width: frame.viewport.size.width)
//
//        if config.verbose {
//            print("Scaled title font to \(adaptedTitleFont.pointSize) points...")
//        }
//
//        for i in 0 ..< screenshots.count {
//            let screenshot = try imageLoader.loadImage(
//                atPath: screenshots[i],
//                forSize: frame.viewport.size,
//                allowDownsampling: config.downsamplingAllowed)
//
//            if config.verbose {
//                print("Framing \(screenshots[i])...")
//            }
//
//            let image = try composer.compose(
//                background: config.background,
//                frame: frame.image,
//                framePadding: frame.padding,
//                viewport: frame.viewport,
//                viewportMask: frame.viewportMask,
//                screenshot: screenshot,
//                titleText: config.titleTexts[i],
//                titleFont: adaptedTitleFont,
//                titleColor: config.titleColor,
//                titlePadding: config.titlePadding)
//
//            guard let outputPath = config.outputPathsByScreenshotPath[screenshots[i]] else {
//                throw NSError(description: "Could not determine output path for \(screenshots[i])")
//            }
//
//            if config.verbose {
//                print("Writing framed image to \(outputPath)...")
//            }
//
//            try writer.write(image, toPath: outputPath)
//        }
//    }
} catch {
    // The cast to `NSError` is mandatory here or otherwise the program will die with a segfault when built through `xcodebuild`.
    // Interestingly, the same does not happen when building with Xcode directly.
    print(CommandLineFormatter().formatError("\((error as NSError).localizedDescription)"))
    exit(1)
}
