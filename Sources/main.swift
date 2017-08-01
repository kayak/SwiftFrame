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

    let config = try Config(options: options)

    if config.verbose {
        config.printSummary()
    }

    for (frame, screenshots) in config.screenshotPathsByFrame {
        let imageLoader = ImageLoader()
        let frameImage = try imageLoader.loadImage(atPath: frame.path)

        let composer = ImageComposer()
        let writer = ImageWriter()

        let adaptedTitleFont = try composer.adapt(
            titleFont: config.titleFont,
            toFitTitleTexts: config.titleTexts,
            titlePadding: config.titlePadding,
            width: frame.viewport.size.width)

        if config.verbose {
            print("Scaled title font to \(adaptedTitleFont.pointSize) points...")
        }

        for i in 0 ..< screenshots.count {
            let screenshot = try imageLoader.loadImage(atPath: screenshots[i])

            if config.downsamplingAllowed {
                let scale = frame.viewport.size.width / screenshot.size.width
                guard scale <= 1, screenshot.size.applying(CGAffineTransform(scaleX: scale, y: scale)).equalTo(frame.viewport.size) else {
                    throw NSError(description: "Dimensions of screenshot \(screenshots[i]) – \(screenshot.size) – "
                        + "cannot be scaled down into viewport – \(frame.viewport.size)")
                }
            } else {
                guard screenshot.size.equalTo(frame.viewport.size) else {
                    throw NSError(description: "Dimensions of screenshot \(screenshots[i]) – \(screenshot.size) – "
                        + "don't match viewport – \(frame.viewport.size)")
                }
            }

            if config.verbose {
                print("Framing \(screenshots[i])...")
            }

            let image = try composer.compose(
                backgroundColor: config.backgroundColor,
                frame: frameImage,
                framePadding: frame.padding,
                viewport: frame.viewport,
                screenshot: screenshot,
                titleText: config.titleTexts[i],
                titleFont: adaptedTitleFont,
                titleColor: config.titleColor,
                titlePadding: config.titlePadding)

            guard let outputPath = config.outputPathsByScreenshotPath[screenshots[i]] else {
                throw NSError(description: "Could not determine output path for \(screenshots[i])")
            }
            
            if config.verbose {
                print("Writing framed image to \(outputPath)...")
            }
            
            try writer.write(image, toPath: outputPath)
        }
    }
} catch {
    // The cast to `NSError` is mandatory here or otherwise the program will die with a segfault when built through `xcodebuild`.
    // Interestingly, the same does not happen when building with Xcode directly. 
    print("Error: \((error as NSError).localizedDescription)")
    exit(1)
}
