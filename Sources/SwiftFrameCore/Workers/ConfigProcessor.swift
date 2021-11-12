import AppKit
import Foundation

public class ConfigProcessor {

    // MARK: - Properties

    private var data: ConfigData
    let verbose: Bool

    // MARK: - Init

    public init(configURL: URL, verbose: Bool) throws {
        data = try DecodableParser.parseData(fromURL: configURL)
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

        if data.clearDirectories {
            let clearingStart = CFAbsoluteTimeGetCurrent()
            try FileManager.default.ky_clearDirectories(data.outputPaths, localeFolders: Array(data.titles.keys))
            let clearingDiff = CFAbsoluteTimeGetCurrent() - clearingStart
            print("Cleared output directories in \(String(format: "%.3f", clearingDiff)) seconds\n")
        }

        print("Rendering...\n")

        let start = CFAbsoluteTimeGetCurrent()
        try data.deviceData.forEach { deviceData in
            try process(deviceData: deviceData)
        }

        print("All done!".formattedGreen())
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Rendered and sliced all screenshots in \(String(format: "%.3f", diff)) seconds")
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

            let associatedStrings = try data.makeAssociatedStrings(for: deviceData, locale: locale)
            let fontSizesByGroup = try data.makeSharedFontSizes(for: associatedStrings)

            try composer.addStrings(
                associatedStrings,
                maxFontSizeByGroup: fontSizesByGroup,
                font: data.fontSource.font(),
                color: data.textColorSource.color,
                maxFontSize: data.maxFontSize)

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

    func printVerbose(_ args: Any..., insetByTabs tabs: Int = 0) {
        if verbose {
            let formattedArgs = args.map { String(describing: $0) }.joined(separator: " ")
            ky_print(formattedArgs, insetByTabs: tabs)
        }
    }

}
