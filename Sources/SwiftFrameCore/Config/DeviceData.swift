import AppKit
import Foundation

public struct DeviceData: Decodable, ConfigValidatable {

    // MARK: - Properties

    private let kScreenshotExtensions = Set(["png", "jpg", "jpeg"])

    let outputSuffix: String
    let templateImagePath: FileURL
    private let screenshotsPath: FileURL

    internal private(set) var screenshotsGroupedByLocale: [String: [String: URL]]!
    internal private(set) var templateImage: NSBitmapImageRep?
    internal private(set) var screenshotData = [ScreenshotData]()
    internal private(set) var textData = [TextData]()

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case outputSuffix
        case screenshotsPath = "screenshots"
        case templateImagePath = "templateFile"
        case screenshotData
        case textData
    }

    // MARK: - Init

    internal init(
        outputSuffix: String,
        templateImagePath: FileURL,
        screenshotsPath: FileURL,
        screenshotsGroupedByLocale: [String: [String: URL]]? = nil,
        templateImage: NSBitmapImageRep? = nil,
        screenshotData: [ScreenshotData] = [ScreenshotData](),
        textData: [TextData] = [TextData]()) {
        self.outputSuffix = outputSuffix
        self.templateImagePath = templateImagePath
        self.screenshotsPath = screenshotsPath
        self.screenshotsGroupedByLocale = screenshotsGroupedByLocale
        self.templateImage = templateImage
        self.screenshotData = screenshotData
        self.textData = textData
    }

    // MARK: - Methods

    func makeProcessedData() throws -> DeviceData {
        guard let rep = ImageLoader.loadRepresentation(at: templateImagePath.absoluteURL) else {
            throw NSError(description: "Error while loading template image at path \(templateImagePath.absoluteString)")
        }

        var parsedScreenshots = [String: [String: URL]]()
        try screenshotsPath.absoluteURL.subDirectories.forEach { folder in
            var dictionary = [String: URL]()
            try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                .filter { kScreenshotExtensions.contains($0.pathExtension.lowercased()) }
                .forEach { dictionary[$0.lastPathComponent] = $0 }
            parsedScreenshots[folder.lastPathComponent] = dictionary
        }

        let processedTextData = try textData.map { try $0.makeProcessedData(size: rep.size) }
        let processedScreenshotData = screenshotData
            .map { $0.makeProcessedData(size: rep.size)}
            .sorted { $0.zIndex < $1.zIndex }

        return DeviceData(
            outputSuffix: outputSuffix,
            templateImagePath: templateImagePath,
            screenshotsPath: screenshotsPath,
            screenshotsGroupedByLocale: parsedScreenshots,
            templateImage: rep,
            screenshotData: processedScreenshotData,
            textData: processedTextData)
    }

    // MARK: - ConfigValidatable

    func validate() throws {
        try screenshotsGroupedByLocale.forEach { localeDict in
            guard let first = localeDict.value.first?.value else {
                return
            }
            try localeDict.value.forEach {
                if $0.value.bitmapImageRep?.nativeSize != first.bitmapImageRep?.nativeSize {
                    throw NSError(description: "Image file with mismatching resolution found in folder \"\(localeDict.key)\"")
                }
            }
        }

        // Now that we know all screenshots have the same resolution, we can validate that template image is multiple in width
        if let screenshotSize = screenshotsGroupedByLocale.first?.value.first?.value.bitmapImageRep?.nativeSize {
            guard
                let templateImageSize = templateImage?.nativeSize,
                templateImageSize.width.truncatingRemainder(dividingBy: screenshotSize.width) == 0.00
            else {
                throw NSError(description: "Template image for output suffix \"\(outputSuffix)\" is not a multiple in width as associated screenshot width")
            }
        }

        try screenshotData.forEach { try $0.validate() }
        try textData.forEach { try $0.validate() }

        let screenshotNames = screenshotData.map { $0.screenshotName }
        try screenshotsGroupedByLocale.forEach { localeDict in
            try screenshotNames.forEach { name in
                if localeDict.value[name] == nil {
                    throw NSError(description: "Screenshot folder \(localeDict.key) does not contain a screenshot named \"\(name)\"")
                }
            }
        }
    }

    func printSummary(insetByTabs tabs: Int) {
        CommandLineFormatter.printKeyValue("Ouput suffix", value: outputSuffix, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Template file path", value: templateImagePath.absoluteString, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Screenshot folders", value: screenshotsGroupedByLocale.count, insetBy: tabs)
        screenshotData.forEach { $0.printSummary(insetByTabs: tabs) }
        textData.forEach { $0.printSummary(insetByTabs: tabs) }
    }

}
