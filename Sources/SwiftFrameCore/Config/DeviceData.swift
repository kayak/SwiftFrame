import AppKit
import Foundation

public struct DeviceData: Decodable, ConfigValidatable {

    // MARK: - Properties

    private let kScreenshotExtensions = Set(["png", "jpg", "jpeg"])

    let outputSuffix: String
    let templateImagePath: FileURL
    private let screenshotsPath: FileURL
    let sliceSizeOverride: DecodableSize?

    @DecodableDefault.IntZero var gapWidth: Int

    private(set) var screenshotsGroupedByLocale: [String: [String: URL]]!
    private(set) var templateImage: NSBitmapImageRep?
    private(set) var screenshotData = [ScreenshotData]()
    private(set) var textData = [TextData]()

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case outputSuffix
        case screenshotsPath = "screenshots"
        case templateImagePath = "templateFile"
        case sliceSizeOverride
        case screenshotData
        case textData
        case gapWidth
    }

    // MARK: - Init

    internal init(
        outputSuffix: String,
        templateImagePath: FileURL,
        screenshotsPath: FileURL,
        sliceSizeOverride: DecodableSize? = nil,
        screenshotsGroupedByLocale: [String: [String: URL]]? = nil,
        templateImage: NSBitmapImageRep? = nil,
        screenshotData: [ScreenshotData] = [ScreenshotData](),
        textData: [TextData] = [TextData](),
        gapWidth: Int = 0)
    {
        self.outputSuffix = outputSuffix
        self.templateImagePath = templateImagePath
        self.screenshotsPath = screenshotsPath
        self.sliceSizeOverride = sliceSizeOverride
        self.screenshotsGroupedByLocale = screenshotsGroupedByLocale
        self.templateImage = templateImage
        self.screenshotData = screenshotData
        self.textData = textData
        self.gapWidth = gapWidth
    }

    // MARK: - Methods

    func makeProcessedData(localesRegex: NSRegularExpression?) throws -> DeviceData {
        guard let rep = ImageLoader.loadRepresentation(at: templateImagePath.absoluteURL) else {
            throw NSError(description: "Error while loading template image at path \(templateImagePath.absoluteString)")
        }

        var parsedScreenshots = [String: [String: URL]]()
        try screenshotsPath.absoluteURL.subDirectories.filterByFileOrFoldername(regex: localesRegex).forEach { folder in
            var dictionary = [String: URL]()
            try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                .filter { url in
                    kScreenshotExtensions.contains(url.pathExtension.lowercased())
                    && screenshotData.contains(where: { $0.screenshotName == url.lastPathComponent })
                }.forEach { dictionary[$0.lastPathComponent] = $0 }
            parsedScreenshots[folder.lastPathComponent] = dictionary
        }

        let processedTextData = try textData.map { try $0.makeProcessedData(size: rep.size) }
        let processedScreenshotData = screenshotData
            .map { $0.makeProcessedData(size: rep.size) }
            .sorted { $0.zIndex < $1.zIndex }

        return DeviceData(
            outputSuffix: outputSuffix,
            templateImagePath: templateImagePath,
            screenshotsPath: screenshotsPath,
            sliceSizeOverride: sliceSizeOverride,
            screenshotsGroupedByLocale: parsedScreenshots,
            templateImage: rep,
            screenshotData: processedScreenshotData,
            textData: processedTextData,
            gapWidth: gapWidth)
    }

    // MARK: - ConfigValidatable

    func validate() throws {
        guard !screenshotsGroupedByLocale.isEmpty else {
            throw NSError(description: "No screenshots were loaded, most likely caused by a faulty regular expression")
        }

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
        // plus specified gap width in between
        if let screenshotSize = sliceSizeOverride?.cgSize ?? NSBitmapImageRep.ky_loadFromURL(screenshotsGroupedByLocale.first?.value.first?.value)?.ky_nativeSize {
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
        let remainingPixels = templateSize.width.truncatingRemainder(dividingBy: screenshotSize.width)
        if gapWidth == 0 {
            guard remainingPixels == 0 else {
                throw NSError(
                    description: "Template image for output suffix \"\(outputSuffix)\" is not a multiple in width as associated screenshot width",
                    expectation: "Width should be multiple of \(Int(screenshotSize.width))px",
                    actualValue: "\(Int(screenshotSize.width))px")
            }
        } else {
            // Make sure there's at least one gap
            guard remainingPixels.truncatingRemainder(dividingBy: CGFloat(gapWidth)) == 0 && remainingPixels != 0 else {
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
        CommandLineFormatter.printKeyValue(
            "Screenshot folders",
            value: screenshotsGroupedByLocale.isEmpty ? "none" : screenshotsGroupedByLocale.keys.joined(separator: ", "),
            insetBy: tabs)
        screenshotData.forEach { $0.printSummary(insetByTabs: tabs) }
        textData.forEach { $0.printSummary(insetByTabs: tabs) }
    }

}
