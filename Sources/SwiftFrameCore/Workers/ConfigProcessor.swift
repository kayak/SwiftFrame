import AppKit
import Foundation
import Synchronization

public class ConfigProcessor: VerbosePrintable {

    // MARK: - Properties

    static var shouldColorOutput: Bool {
        get {
            colorOutputSetting.withLock { $0 }
        }
        set {
            colorOutputSetting.withLock { $0 = newValue }
        }
    }

    private static let colorOutputSetting = Mutex(true)

    public let verbose: Bool

    private let shouldValidateManually: Bool
    private let shouldOutputWholeImage: Bool
    private let shouldClearDirectories: Bool

    private var data: ConfigData

    // MARK: - Init

    public init(
        configURL: URL,
        verbose: Bool,
        shouldValidateManually: Bool,
        shouldOutputWholeImage: Bool,
        shouldClearDirectories: Bool,
        shouldColorOutput: Bool
    ) throws {
        data = try DecodableParser.parseData(fromURL: configURL)
        self.verbose = verbose
        self.shouldValidateManually = shouldValidateManually
        self.shouldOutputWholeImage = shouldOutputWholeImage
        self.shouldClearDirectories = shouldClearDirectories
        ConfigProcessor.shouldColorOutput = shouldColorOutput
    }

    // MARK: - Methods

    public func validate() throws {
        try data.process()
        try data.validate()
    }

    public func run() throws {
        if shouldValidateManually {
            data.printSummary(insetByTabs: 0)
            print("Press any key to continue")
            _ = readLine()
        }

        print("Parsed and validated config file\n")

        if shouldClearDirectories {
            let clearingStart = CFAbsoluteTimeGetCurrent()
            try FileManager.default.ky_clearDirectories(data.outputPaths, localeFolders: Array(data.titles.keys))
            printElapsedTime("Clear output directories", startTime: clearingStart)
        }

        let stringProcessingStart = CFAbsoluteTimeGetCurrent()

        for deviceData in data.deviceData {
            for (locale, _) in deviceData.screenshotsGroupedByLocale {
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

        let deviceData = data.deviceData
        let outputPaths = data.outputPaths
        let outputFormat = data.outputFormat

        DispatchQueue.concurrentPerform(iterations: deviceData.count) { [verbose, shouldOutputWholeImage] index in
            ky_executeOrExit(verbose: verbose) {
                try ConfigProcessor.process(
                    deviceData: deviceData[index],
                    outputPaths: outputPaths,
                    outputFormat: outputFormat,
                    shouldOutputWholeImage: shouldOutputWholeImage
                )
            }
        }

        print("All done!".formattedGreen())
        printElapsedTime("Rendered and sliced all screenshots", startTime: imageRenderingStart)
    }

    private static func process(
        deviceData: DeviceData,
        outputPaths: [FileURL],
        outputFormat: FileFormat,
        shouldOutputWholeImage: Bool
    ) throws {
        let group = DispatchGroup()

        for (locale, imageDict) in deviceData.screenshotsGroupedByLocale {
            group.enter()
            defer { group.leave() }

            guard let templateImage = deviceData.templateImage else {
                throw NSError(description: "No template image found")
            }

            let sliceSize = try SliceSizeCalculator.calculateSliceSize(
                templateImageSize: templateImage.ky_nativeSize,
                numberOfSlices: deviceData.numberOfSlices,
                gapWidth: deviceData.gapWidth
            )

            let composer = try ImageComposer(canvasSize: templateImage.ky_nativeSize)
            try composer.add(screenshots: imageDict, with: deviceData.screenshotData, for: locale)
            composer.addTemplateImage(templateImage)

            try composer.addStrings(deviceData.textData, locale: locale, deviceIdentifier: deviceData.outputSuffixes.joined())

            try ImageWriter.finish(
                context: composer.context,
                with: outputPaths,
                sliceSize: sliceSize,
                gapWidth: deviceData.gapWidth,
                outputWholeImage: shouldOutputWholeImage,
                locale: locale,
                suffixes: deviceData.outputSuffixes,
                format: outputFormat
            )

            for suffix in deviceData.outputSuffixes {
                print("Finished \(locale)-\(suffix)")
            }
        }

        group.wait()
    }

}
