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
        let requiredFileWrites = data.deviceData.count * data.titles.count

        let workGroup = DispatchGroup()
        workGroup.enter()

        let resultCompletion: (DispatchTimeoutResult) throws -> Void = {
            switch $0 {
            case .success:
                fileWriteFinishers += 1
                print("success, \(fileWriteFinishers)/\(requiredFileWrites)")
                if fileWriteFinishers == requiredFileWrites {
                    workGroup.leave()
                }
            case .timedOut:
                throw NSError(description: "Image writing timed out")
            }
        }

        let start = CFAbsoluteTimeGetCurrent()

        data.deviceData.enumerated().forEach {
            let deviceData = $0.element
            DispatchQueue(label: deviceData.outputSuffix + "-\($0.offset)-queue").async { [weak self] in
                do {
                    try self?.process(deviceData: deviceData, completion: resultCompletion)
                } catch let error {
                    print(error.localizedDescription.formattedRed())
                    exit(1)
                }
            }
        }

        workGroup.wait()
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("All done!".formattedGreen())

        printVerbose("Rendered and sliced all screenshots in \(String(format: "%.3f", diff)) seconds")
    }

    private func process(deviceData: DeviceData, completion: @escaping (DispatchTimeoutResult) throws -> Void) throws {
        try deviceData.screenshotsGroupedByLocale.forEach { locale, imageDict in
            print("\(deviceData.outputSuffix) - \(locale)".formattedUnderlined())

            guard let sliceSize = imageDict.first?.value.bitmapImageRep?.nativeSize else {
                throw NSError(description: "No screenshots supplied, so it's impossible to slice into the correct size")
            }

            print("Rendering screenshots")

            let composer = try ImageComposer(canvasSize: deviceData.templateImage.nativeSize, verbose: verbose)
            try composer.add(screenshots: imageDict, with: deviceData.screenshotData, for: locale)
            try composer.addTemplateImage(deviceData.templateImage)

            print("Rendering text titles")

            let processedStrings = try data.makeAssociatedStrings(for: deviceData, locale: locale)

            try composer.addStrings(
                processedStrings.strings,
                maxFontSizeByGroup: processedStrings.fontSizes,
                font: data.fontSource.makeFont(),
                color: data.textColorSource.color,
                maxFontSize: data.maxFontSize)

            print("Writing images asynchronously...\n")

            try ImageWriter.finish(
                context: composer.context,
                with: data.outputPaths,
                sliceSize: sliceSize,
                outputWholeImage: data.outputWholeImage,
                locale: locale,
                suffix: deviceData.outputSuffix,
                completion: completion)
        }
    }

}
