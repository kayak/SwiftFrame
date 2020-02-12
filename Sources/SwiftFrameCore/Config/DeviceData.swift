import AppKit
import Foundation

public struct DeviceData: Decodable, ConfigValidatable {

    // MARK: - Properties

    private let kScreenshotExtensions = Set<String>(arrayLiteral: "png", "jpg", "jpeg")

    let outputSuffix: String
    let templateImagePath: LocalURL
    private let screenshotsPath: LocalURL

    internal private(set) var screenshots: [String: [String: NSBitmapImageRep]]!
    internal private(set) var templateImage: NSBitmapImageRep!
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
        templateImagePath: LocalURL,
        screenshotsPath: LocalURL,
        screenshots: [String : [String : NSBitmapImageRep]]? = nil,
        templateImage: NSBitmapImageRep? = nil,
        screenshotData: [ScreenshotData] = [ScreenshotData](),
        textData: [TextData] = [TextData]())
    {
        self.outputSuffix = outputSuffix
        self.templateImagePath = templateImagePath
        self.screenshotsPath = screenshotsPath
        self.screenshots = screenshots
        self.templateImage = templateImage
        self.screenshotData = screenshotData
        self.textData = textData
    }

    // MARK: - Methods

    func makeProcessedData() throws -> DeviceData {
        guard let rep = ImageLoader.loadRepresentation(at: templateImagePath.absoluteURL) else {
            throw NSError(description: "Error while loading template image at path \(templateImagePath.absoluteString)")
        }

        var parsedScreenshots = [String : [String : NSBitmapImageRep]]()
        try screenshotsPath.absoluteURL.subDirectories.forEach { folder in
            let imageFiles = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                .filter { kScreenshotExtensions.contains($0.pathExtension.lowercased()) }
            let imagesDictionary = imageFiles.reduce(into: [String: NSBitmapImageRep]()) { dictionary, url in
                let rep = ImageLoader.loadRepresentation(at: url)
                dictionary[url.lastPathComponent] = rep
            }
            parsedScreenshots[folder.lastPathComponent] = imagesDictionary
        }

        let processedTextData = try textData.map { try $0.makeProcessedData(size: rep.size) }
        let processedScreenshotData = screenshotData
            .map { $0.makeProcessedData(size: rep.size)}
            .sorted { $0.zIndex < $1.zIndex }

        return DeviceData(
            outputSuffix: outputSuffix,
            templateImagePath: templateImagePath,
            screenshotsPath: screenshotsPath,
            screenshots: parsedScreenshots,
            templateImage: rep,
            screenshotData: processedScreenshotData,
            textData: processedTextData)
    }

    // MARK: - ConfigValidatable

    func validate() throws {
        try screenshots.forEach { localeDict in
            guard let first = localeDict.value.first?.value else {
                return
            }
            try localeDict.value.forEach {
                if $0.value.nativeSize != first.nativeSize {
                    throw NSError(description: "Image file with mismatching resolution found in folder \"\(localeDict.key)\"")
                }
            }
        }

        // Now that we know all screenshots have the same resolution, we can validate that template image is multiple in width
        if let screenshotSize = screenshots.first?.value.first?.value.nativeSize {
            guard templateImage.nativeSize.width.truncatingRemainder(dividingBy: screenshotSize.width) == 0.00 else {
                throw NSError(description: "Template image for output suffix \"\(outputSuffix)\" is not a multiple in width as associated screenshot width")
            }
        }

        try screenshotData.forEach { try $0.validate() }
        try textData.forEach { try $0.validate() }

        let screenshotNames = screenshotData.map { $0.screenshotName }
        try screenshots.forEach { localeDict in
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
        CommandLineFormatter.printKeyValue("Screenshot folders", value: screenshots.count, insetBy: tabs)
        screenshotData.forEach { $0.printSummary(insetByTabs: tabs) }
        textData.forEach { $0.printSummary(insetByTabs: tabs) }
    }

}
