import AppKit
import Foundation

struct DeviceData: Decodable, ConfigValidateable {

    // MARK: - Properties

    private let kScreenshotExtensions = Set(["png", "jpg", "jpeg"])

    let outputSuffixes: [String]
    let templateImagePath: FileURL
    let screenshotsPath: FileURL
    let numberOfSlices: Int

    @DecodableDefault.IntZero var gapWidth: Int

    private(set) var screenshotsGroupedByLocale: [String: [String: URL]]!
    private(set) var templateImage: NSBitmapImageRep?
    private(set) var screenshotData = [ScreenshotData]()
    private(set) var textData = [TextData]()

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case outputSuffixes
        case screenshotsPath = "screenshots"
        case templateImagePath = "templateFile"
        case screenshotData
        case textData
        case gapWidth
        case numberOfSlices
    }

    // MARK: - Init

    init(
        outputSuffixes: [String],
        templateImagePath: FileURL,
        screenshotsPath: FileURL,
        numberOfSlices: Int,
        screenshotsGroupedByLocale: [String: [String: URL]]? = nil,
        templateImage: NSBitmapImageRep? = nil,
        screenshotData: [ScreenshotData] = [ScreenshotData](),
        textData: [TextData] = [TextData](),
        gapWidth: Int = 0)
    {
        self.outputSuffixes = outputSuffixes
        self.templateImagePath = templateImagePath
        self.screenshotsPath = screenshotsPath
        self.numberOfSlices = numberOfSlices
        self.screenshotsGroupedByLocale = screenshotsGroupedByLocale
        self.templateImage = templateImage
        self.screenshotData = screenshotData
        self.textData = textData
        self.gapWidth = gapWidth
    }

    // MARK: - Methods

    func makeProcessedData(localesRegex: Regex<AnyRegexOutput>?) throws -> DeviceData {
        guard let templateImage = ImageLoader.loadRepresentation(at: templateImagePath.absoluteURL) else {
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

        let processedTextData = try textData.map { try $0.makeProcessedData(size: templateImage.size) }
        let processedScreenshotData = screenshotData
            .map { $0.makeProcessedData(size: templateImage.size) }
            .sorted { $0.zIndex < $1.zIndex }

        return DeviceData(
            outputSuffixes: outputSuffixes,
            templateImagePath: templateImagePath,
            screenshotsPath: screenshotsPath,
            numberOfSlices: numberOfSlices,
            screenshotsGroupedByLocale: parsedScreenshots,
            templateImage: templateImage,
            screenshotData: processedScreenshotData,
            textData: processedTextData,
            gapWidth: gapWidth
        )
    }

    // MARK: - ConfigValidateable

    func validate() throws {
        guard !screenshotsGroupedByLocale.isEmpty else {
            throw NSError(description: "No screenshots were loaded, most likely caused by a faulty regular expression")
        }

        guard numberOfSlices > 0 else {
            throw NSError(
                description: "Invalid numberOfSlices value",
                expectation: "numberOfSlices value should be >= 1",
                actualValue: "numberOfSlices value is \(numberOfSlices)"
            )
        }

        guard gapWidth >= 0 else {
            throw NSError(
                description: "Invalid gapWidth value",
                expectation: "gapWidth value should be >= 0 or ommitted from config",
                actualValue: "gapWdith value is \(gapWidth)"
            )
        }

        if let templateImage {
            _ = try SliceSizeCalculator.calculateSliceSize(
                templateImageSize: templateImage.ky_nativeSize,
                numberOfSlices: numberOfSlices,
                gapWidth: gapWidth
            )
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
        CommandLineFormatter.printKeyValue("Ouput suffixes", value: outputSuffixes.joined(separator: ", "), insetBy: tabs)
        CommandLineFormatter.printKeyValue("Template file path", value: templateImagePath.path, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Number of slices", value: numberOfSlices, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Gap Width", value: gapWidth, insetBy: tabs)

        if let templateImage {
            let sliceSize = try? SliceSizeCalculator.calculateSliceSize(
                templateImageSize: templateImage.ky_nativeSize,
                numberOfSlices: numberOfSlices,
                gapWidth: gapWidth
            )
            CommandLineFormatter.printKeyValue("Output slice size", value: sliceSize?.configValidationRepresentation, insetBy: tabs)
        }

        CommandLineFormatter.printKeyValue(
            "Screenshot folders",
            value: screenshotsGroupedByLocale.isEmpty ? "none" : screenshotsGroupedByLocale.keys.joined(separator: ", "),
            insetBy: tabs
        )

        screenshotData.forEach { $0.printSummary(insetByTabs: tabs) }
        textData.forEach { $0.printSummary(insetByTabs: tabs) }
    }

}
