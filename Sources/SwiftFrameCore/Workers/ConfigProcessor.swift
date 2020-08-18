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

        print("Parsed and validated config file")

        if data.clearDirectories {
            print("Clearing Output Directories")
            try FileManager.default.ky_clearDirectories(data.outputPaths, localeFolders: Array(data.titles.keys))
        }

        print("Rendering...\n")

        // We need a special semaphore here, since the creation of the attributed strings has to happen
        // on the main thread and anything else can happen asynchronously but we still want to finish
        // execution only when everything has finished
        let semaphore = RunLoopSemaphore()

        let start = CFAbsoluteTimeGetCurrent()

        DispatchQueue.global(qos: .userInitiated).async {
            let group = DispatchGroup()

            self.data.deviceData.forEach { deviceData in
                group.enter()
                DispatchQueue.global(qos: .userInitiated).ky_asyncOrExit { [weak self] in
                    try self?.process(deviceData: deviceData)
                    group.leave()
                }
            }

            group.wait()
            DispatchQueue.main.async {
                semaphore.signal()
            }
        }

        semaphore.wait()

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

            printVerbose("Writing images for device \"\(deviceData.outputSuffix)\" for locale \"\(locale)\" asynchronously...")

            try ImageWriter.finish(
                context: composer.context,
                with: data.outputPaths,
                sliceSize: sliceSize,
                gapWidth: deviceData.gapWidth,
                outputWholeImage: data.outputWholeImage,
                locale: locale,
                suffix: deviceData.outputSuffix,
                format: data.outputFormat)

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
