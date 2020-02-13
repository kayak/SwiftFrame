import Foundation

protocol VerbosePrintable {
    var verbose: Bool { get }
}

extension VerbosePrintable {
    func printVerbose(_ args: Any..., insetByTabs tabs: Int = 0) {
        if verbose {
            let formattedArgs = args.map { String(describing: $0) }.joined(separator: " ")
            print(formattedArgs, insetByTabs: tabs)
        }
    }
}

public class ConfigProcessor: VerbosePrintable {

    // MARK: - Properties

    private var data: ConfigData
    private let imageWriter = ImageWriter()
    var verbose: Bool

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

        var fileWriteFinishers = 0
        let workGroup = DispatchGroup()
        workGroup.enter()

        // Run and measure elapsed time, for development purposes only
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

                let addedScreenshotsTime = CFAbsoluteTimeGetCurrent()

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
                { [weak self] result in
                    switch result {
                    case .success:
                        fileWriteFinishers += 1
                        if fileWriteFinishers == self?.data.deviceData.count {
                            workGroup.leave()
                        }
                    case .timedOut:
                        throw NSError(description: "Image writing timed out")
                    }

                }

                let screenshotDuration = addedScreenshotsTime - compositionStart
                let compositionDuration = compositionFinish - addedScreenshotsTime

                printVerbose("Composed screenshots in \(String(format: "%.3f", screenshotDuration)) seconds")
                printVerbose("Composed titles in \(String(format: "%.3f", compositionDuration)) seconds")
                printVerbose("Writing images asynchronously...\n")
            }
        }

        workGroup.wait()
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("All done!".formattedGreen())

        printVerbose("Rendered and sliced all screenshots in \(String(format: "%.3f", diff)) seconds")
    }

}
