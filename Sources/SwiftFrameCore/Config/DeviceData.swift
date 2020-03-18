import AppKit
import Foundation

public struct DeviceData: Decodable, ConfigValidatable {

    // MARK: - Properties

    private let kScreenshotExtensions = Set(["png", "jpg", "jpeg"])

    let outputSuffix: String
    let templateImagePath: FileURL
    private let _gapWidth: Int?
    private let screenshotsPath: FileURL

    private(set) var screenshotsGroupedByLocale: [String: [String: URL]]!
    private(set) var templateImage: NSBitmapImageRep?
    private(set) var screenshotData = [ScreenshotData]()
    private(set) var textData = [TextData]()

    var gapWidth: Int {
        _gapWidth ?? 0
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case outputSuffix
        case screenshotsPath = "screenshots"
        case templateImagePath = "templateFile"
        case screenshotData
        case textData
        case _gapWidth = "gapWidth"
    }

    // MARK: - Init

    internal init(
        outputSuffix: String,
        templateImagePath: FileURL,
        screenshotsPath: FileURL,
        screenshotsGroupedByLocale: [String: [String: URL]]? = nil,
        templateImage: NSBitmapImageRep? = nil,
        screenshotData: [ScreenshotData] = [ScreenshotData](),
        textData: [TextData] = [TextData](),
        gapWidth: Int? = 0)
    {
        self.outputSuffix = outputSuffix
        self.templateImagePath = templateImagePath
        self.screenshotsPath = screenshotsPath
        self.screenshotsGroupedByLocale = screenshotsGroupedByLocale
        self.templateImage = templateImage
        self.screenshotData = screenshotData
        self.textData = textData
        self._gapWidth = gapWidth
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
            .sorted { $0.zIndex ?? 0 < $1.zIndex ?? 0 }

        return DeviceData(
            outputSuffix: outputSuffix,
            templateImagePath: templateImagePath,
            screenshotsPath: screenshotsPath,
            screenshotsGroupedByLocale: parsedScreenshots,
            templateImage: rep,
            screenshotData: processedScreenshotData,
            textData: processedTextData,
            gapWidth: _gapWidth)
    }

    // MARK: - ConfigValidatable

    func validate() throws {
        try screenshotsGroupedByLocale.forEach { localeDict in
            guard let first = localeDict.value.first?.value else {
                return
            }
            try localeDict.value.forEach {
                if let size = NSBitmapImageRep.ky_loadFromURL($0.value)?.ky_nativeSize, size != NSBitmapImageRep.ky_loadFromURL(first)?.ky_nativeSize {
                    throw NSError(
                        description: "Image file with mismatching resolution found in folder \"\(localeDict.key)\"",
                        expectation: "All screenshots should have the same resolution",
                        actualValue: "Screenshot with dimensions \(size)")
                }
            }
        }

        // Now that we know all screenshots have the same resolution, we can validate that template image is multiple in width
        if let screenshotSize = NSBitmapImageRep.ky_loadFromURL(screenshotsGroupedByLocale.first?.value.first?.value)?.ky_nativeSize {
            guard let templateImageSize = templateImage?.ky_nativeSize else {
                throw NSError(description: "Template image for output suffix \"\(outputSuffix)\" could not be loaded for validation")
            }
            try validateSize(templateImageSize, screenshotSize: screenshotSize)
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

    private func validateSize(_ templateSize: CGSize, screenshotSize: CGSize) throws {
        if gapWidth == 0 {
            guard templateSize.width.truncatingRemainder(dividingBy: screenshotSize.width) == 0 else {
                throw NSError(
                    description: "Template image for output suffix \"\(outputSuffix)\" is not a multiple in width as associated screenshot width",
                    expectation: "Width should be multiple of \(Int(screenshotSize.width))px",
                    actualValue: "\(Int(screenshotSize.width))px")
            }
        } else {
            let remainingPixels = templateSize.width.truncatingRemainder(dividingBy: screenshotSize.width)
            // Make sure there's at least one gap
            if remainingPixels.truncatingRemainder(dividingBy: CGFloat(gapWidth)) != 0 || remainingPixels == 0 {
                throw NSError(
                    description: "Template image for output suffix \"\(outputSuffix)\" is not a multiple in width as associated screenshot width",
                    expectation: "Template image width should be = (x * screenshot width) + (x - 1) * gap width",
                    actualValue: "Template image width: \(templateSize.width)px, screenshot width: \(screenshotSize.width), gap width: \(gapWidth)")
            }
        }
    }

    func printSummary(insetByTabs tabs: Int) {
        CommandLineFormatter.printKeyValue("Ouput suffix", value: outputSuffix, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Template file path", value: templateImagePath.path, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Gap Width", value: gapWidth, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Screenshot folders", value: screenshotsGroupedByLocale.count, insetBy: tabs)
        screenshotData.forEach { $0.printSummary(insetByTabs: tabs) }
        textData.forEach { $0.printSummary(insetByTabs: tabs) }
    }

}
