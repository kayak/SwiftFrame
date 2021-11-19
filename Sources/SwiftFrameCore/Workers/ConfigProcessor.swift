import AppKit
import Foundation

public class ConfigProcessor: VerbosePrintable {

    // MARK: - Properties

    static var noColorOutput = true

    public let verbose: Bool
    private let noManualValidation: Bool
    private var data: ConfigData

    // MARK: - Init

    public init(configURL: URL, verbose: Bool, noManualValidation: Bool, noColorOutput: Bool) throws {
        data = try DecodableParser.parseData(fromURL: configURL)
        self.verbose = verbose
        self.noManualValidation = noManualValidation
        ConfigProcessor.noColorOutput = noColorOutput
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
        if verbose && !noManualValidation {
            data.printSummary(insetByTabs: 0)
            print("Press return key to continue")
            _ = readLine()
        }

        print("Parsed and validated config file\n")

        if data.clearDirectories {
            let clearingStart = CFAbsoluteTimeGetCurrent()
            try FileManager.default.ky_clearDirectories(data.outputPaths, localeFolders: Array(data.titles.keys))
            printElapsedTime("Clear output directories", startTime: clearingStart)
        }

        let stringProcessingStart = CFAbsoluteTimeGetCurrent()

        try data.deviceData.forEach { deviceData in
            try deviceData.screenshotsGroupedByLocale.forEach { locale, _ in
                printVerbose("Processing strings for locale \(locale) (\(deviceData.outputSuffixes.first ?? "unknown device"))")

                let associatedStrings = try data.makeAssociatedStrings(for: deviceData, locale: locale)
                let fontSizesByGroup = try data.makeSharedFontSizes(for: associatedStrings)
                try AttributedStringCache.shared.process(
                    associatedStrings,
                    locale: locale,
                    deviceIdentifier: deviceData.outputSuffixes.joined(),
                    maxFontSizeByGroup: fontSizesByGroup,
                    font: try data.fontSource.font(),
                    color: data.textColorSource.color,
                    maxFontSize: data.maxFontSize
                )
            }
        }

        printElapsedTime("Parse HTML strings into attributed strings", startTime: stringProcessingStart)

        print("\nRendering...\n")

        let imageRenderingStart = CFAbsoluteTimeGetCurrent()

        let group = DispatchGroup()

        data.deviceData.forEach { deviceData in
            group.enter()
            DispatchQueue.global(qos: .utility).ky_asyncOrExit(verbose: verbose) { [weak self] in
                try self?.process(deviceData: deviceData)
                group.leave()
            }
        }

        group.wait()

        print("All done!".formattedGreen())
        printElapsedTime("Rendered and sliced all screenshots", startTime: imageRenderingStart)
    }

    private func process(deviceData: DeviceData) throws {
        let group = DispatchGroup()

        try deviceData.screenshotsGroupedByLocale.forEach { locale, imageDict in
            group.enter()

            guard let templateImage = deviceData.templateImage else {
                throw NSError(description: "No template image found")
            }

            guard let sliceSize = deviceData.sliceSizeOverride?.cgSize ?? NSBitmapImageRep.ky_loadFromURL(imageDict.first?.value)?.ky_nativeSize else {
                throw NSError(description: "No screenshots supplied, so it's impossible to slice into the correct size")
            }

            let composer = try ImageComposer(canvasSize: templateImage.ky_nativeSize)
            try composer.add(screenshots: imageDict, with: deviceData.screenshotData, for: locale)
            try composer.addTemplateImage(templateImage)

            try composer.addStrings(deviceData.textData, locale: locale, deviceIdentifier: deviceData.outputSuffixes.joined())

            try ImageWriter.finish(
                context: composer.context,
                with: data.outputPaths,
                sliceSize: sliceSize,
                gapWidth: deviceData.gapWidth,
                outputWholeImage: data.outputWholeImage,
                locale: locale,
                suffixes: deviceData.outputSuffixes,
                format: data.outputFormat)

            deviceData.outputSuffixes.forEach { suffix in
                print("Finished \(locale)-\(suffix)")
            }

            group.leave()
        }

        group.wait()
    }

}
