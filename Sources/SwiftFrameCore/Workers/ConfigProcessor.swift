import AppKit
import Foundation
import Yams

public class ConfigProcessor {

    // MARK: - Properties

    private var data: ConfigData
    let verbose: Bool

    // MARK: - Init

    public init(filePath: String, verbose: Bool, format: CommandParser.Result.ConfigFormat) throws {
        let configURL = URL(fileURLWithPath: filePath)
        let bytes = try Data(contentsOf: configURL)

        data = try ConfigProcessor.parseConfigFrom(from: bytes, format: format)
        self.verbose = verbose
    }

    private static func parseConfigFrom(from bytes: Data, format: CommandParser.Result.ConfigFormat) throws -> ConfigData {
        switch format {
        case .json:
            return try JSONDecoder().decode(ConfigData.self, from: bytes)
        case .yaml:
            guard let yamlString = String(data: bytes, encoding: .utf8) else {
                throw NSError(description: "Specified config file was not a text file")
            }
            return try YAMLDecoder().decode(ConfigData.self, from: yamlString)
        }
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

        if data.clearDirectoriesFirst {
            print("Clearing Output Directories")
            try FileManager.default.ky_clearDirectories(data.outputPaths, localeFolders: Array(data.titles.keys))
        }

        print("Rendering...\n")

        var fileWriteFinishers = 0
        let requiredFileWrites = data.deviceData.count * data.titles.count

        // We need a special semaphore here, since the creation of the attributed strings has to happen
        // on the main thread and anything else can happen asynchronously but we still want to finish
        // execution only when everything has finished
        let semaphore = RunLoopSemaphore()

        let resultCompletion: () throws -> Void = {
            fileWriteFinishers += 1
            if fileWriteFinishers == requiredFileWrites {
                DispatchQueue.main.sync { semaphore.signal() }
            }
        }

        let start = CFAbsoluteTimeGetCurrent()

        data.deviceData.enumerated().forEach {
            let deviceData = $0.element
            DispatchQueue.global().ky_asyncOrExit { [weak self] in
                try self?.process(deviceData: deviceData, completion: resultCompletion)
            }
        }

        semaphore.wait()

        print("All done!".formattedGreen())
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Rendered and sliced all screenshots in \(String(format: "%.3f", diff)) seconds")
    }

    private func process(deviceData: DeviceData, completion: @escaping () throws -> Void) throws {
        try deviceData.screenshotsGroupedByLocale.forEach { locale, imageDict in
            guard let templateImage = deviceData.templateImage else { throw NSError(description: "No template image found") }

            guard let sliceSize = NSBitmapImageRep.ky_loadFromURL(imageDict.first?.value)?.ky_nativeSize else {
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
