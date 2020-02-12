import Foundation

public class ConfigProcessor {

    // MARK: - Properties

    private var data: ConfigData
    private let verbose: Bool
    private let imageWriter = ImageWriter()

    // MARK: - Init

    public init(filePath: String, verbose: Bool) throws {
        let configURL = URL(fileURLWithPath: filePath)
        let bytes = try Data(contentsOf: configURL)

        data = try JSONDecoder().decode(ConfigData.self, from: bytes)
        self.verbose = verbose
    }

    // MARK: - Methods

    public func validate() throws {
        try process()
        try data.validate()
    }

    private func process() throws {
        try data.process()
    }

    public func run() throws {
        if verbose {
            data.printSummary(insetByTabs: 0)
            print("Press return key to continue")
            _ = readLine()
        }

        print("Parsed and validated config file\n")

        // Run and measure elapsed time
        let start = CFAbsoluteTimeGetCurrent()

        try data.deviceData.forEach { device in
            try device.screenshots.forEach { locale, imageDict in
                print("\(device.outputSuffix) - \(locale)".formattedUnderlined())

                guard let sliceSize = imageDict.first?.value.bitmapImageRep?.nativeSize else {
                    throw NSError(description: "No screenshots supplied, so it's impossible to slice into the correct size")
                }

                print("Rendering screenshots")

                let compositionStart = CFAbsoluteTimeGetCurrent()

                let composer = try ImageComposer(canvasSize: device.templateImage.nativeSize, verbose: verbose)
                try composer.add(screenshots: imageDict, with: device.screenshotData, for: locale)
                try composer.addTemplateImage(device.templateImage)

                print("Rendering text titles")

                let processedStrings = try data.makeAssociatedStrings(for: device, locale: locale)
                try composer.addStrings(
                    processedStrings.strings,
                    maxFontSizeByGroup: processedStrings.fontSizes,
                    font: data.fontSource.makeFont(),
                    color: data.textColorSource.color,
                    maxFontSize: data.maxFontSize)

                let compositionFinish = CFAbsoluteTimeGetCurrent()

                try imageWriter.finish(
                    context: composer.context,
                    with: data.outputPaths,
                    sliceSize: sliceSize,
                    outputWholeImage: data.outputWholeImage,
                    locale: locale,
                    suffix: device.outputSuffix)

                let compositionDuration = compositionFinish - compositionStart
                let writeDuration = CFAbsoluteTimeGetCurrent() - compositionFinish

                if verbose {
                    print("Composed screenshots and titles in \(String(format: "%.3f", compositionDuration)) seconds")
                    print("Rendered, sliced and wrote screenshots to disk in \(String(format: "%.3f", writeDuration)) seconds")
                }
                print("Done\n")
            }
        }

        let diff = CFAbsoluteTimeGetCurrent() - start
        print("All done!".formattedGreen())

        if verbose {
            print("Rendered and sliced all screenshots in \(String(format: "%.3f", diff)) seconds")
        }
    }

}
