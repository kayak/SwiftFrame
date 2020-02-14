import Foundation

public class ConfigProcessor {

    // MARK: - Properties

    private var data: ConfigData
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

        print("Parsed and validated config file\nRendering...\n")

        var fileWriteFinishers = 0
        let requiredFileWrites = data.deviceData.count * data.titles.count

        let semaphore = RunLoopSemaphore()

        let resultCompletion: () throws -> Void = {
            fileWriteFinishers += 1
            if fileWriteFinishers == requiredFileWrites {
                DispatchQueue.main.sync { semaphore.signal() }
            }
        }

        let start = CFAbsoluteTimeGetCurrent()

        DispatchQueue.global().async { [weak self] in
            self?.data.deviceData.enumerated().forEach {
                let deviceData = $0.element
                DispatchQueue.global().ky_asyncThrowing {
                    try self?.process(deviceData: deviceData, completion: resultCompletion)
                }
            }
        }

        semaphore.wait(timeout: .now() + 100.00)

        print("All done!".formattedGreen())
        let diff = CFAbsoluteTimeGetCurrent() - start
        printVerbose("Rendered and sliced all screenshots in \(String(format: "%.3f", diff)) seconds")
    }

    private func process(deviceData: DeviceData, completion: @escaping () throws -> Void) throws {
        try deviceData.screenshotsGroupedByLocale.forEach { locale, imageDict in
            guard let sliceSize = imageDict.first?.value.bitmapImageRep?.nativeSize else {
                throw NSError(description: "No screenshots supplied, so it's impossible to slice into the correct size")
            }

            let composer = try ImageComposer(canvasSize: deviceData.templateImage.nativeSize)
            try composer.add(screenshots: imageDict, with: deviceData.screenshotData, for: locale)
            try composer.addTemplateImage(deviceData.templateImage)

            let processedStrings = try data.makeAssociatedStrings(for: deviceData, locale: locale)

            try composer.addStrings(
                processedStrings.strings,
                maxFontSizeByGroup: processedStrings.fontSizes,
                font: data.fontSource.makeFont(),
                color: data.textColorSource.color,
                maxFontSize: data.maxFontSize)

            printVerbose("Writing images for device \"\(deviceData.outputSuffix)\" for locale \"\(locale)\" asynchronously...")

            try ImageWriter.finish(
                context: composer.context,
                with: data.outputPaths,
                sliceSize: sliceSize,
                outputWholeImage: data.outputWholeImage,
                locale: locale,
                suffix: deviceData.outputSuffix,
                format: data.outputFormat,
                completion: completion)
        }
    }

    func printVerbose(_ args: Any..., insetByTabs tabs: Int = 0) {
        if verbose {
            let formattedArgs = args.map { String(describing: $0) }.joined(separator: " ")
            print(formattedArgs, insetByTabs: tabs)
        }
    }

}
