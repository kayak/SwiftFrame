import AppKit
import Foundation

let kScreenshotExtensions = Set<String>(arrayLiteral: "png", "jpg", "jpeg")

public struct DeviceData: Decodable, ConfigValidatable {

    // MARK: - Properties

    public let outputSuffix: String
    public let templateImagePath: LocalURL
    private let screenshotsPath: LocalURL
    private let coordinateOriginIsTopLeft: Bool

    public private(set) var screenshots: [String : [String: NSBitmapImageRep]]!
    public private(set) var templateImage: NSBitmapImageRep!
    public private(set) var screenshotData = [ScreenshotData]()
    public private(set) var textData = [TextData]()

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case outputSuffix
        case screenshotsPath = "screenshots"
        case templateImagePath = "templateFile"
        case screenshotData
        case textData
        case coordinateOriginIsTopLeft
    }

    // MARK: - Init

    public init(
        outputSuffix: String,
        templateImagePath: LocalURL,
        screenshotsPath: LocalURL,
        coordinateOriginIsTopLeft: Bool,
        screenshots: [String : [String: NSBitmapImageRep]] = [String : [String: NSBitmapImageRep]](),
        templateImage: NSBitmapImageRep? = nil,
        screenshotData: [ScreenshotData] = [],
        textData: [TextData] = [])
    {
        self.outputSuffix = outputSuffix
        self.templateImagePath = templateImagePath
        self.screenshotsPath = screenshotsPath
        self.coordinateOriginIsTopLeft = coordinateOriginIsTopLeft
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

        let processedTextData = try textData.map { try $0.makeProcessedData(originIsTopLeft: coordinateOriginIsTopLeft, size: rep.size) }
        let processedScreenshotData = screenshotData
            .map { $0.makeProcessedData(originIsTopLeft: coordinateOriginIsTopLeft, size: rep.size)}
            .sorted { $0.zIndex < $1.zIndex }

        return DeviceData(
            outputSuffix: outputSuffix,
            templateImagePath: templateImagePath,
            screenshotsPath: screenshotsPath,
            coordinateOriginIsTopLeft: coordinateOriginIsTopLeft,
            screenshots: parsedScreenshots,
            templateImage: rep,
            screenshotData: processedScreenshotData,
            textData: processedTextData)
    }

    func groupTextData(with groups: [TextGroup]) -> [TextGroup: [TextData]] {
        var dict = [TextGroup: [TextData]]()
        groups.forEach { group in
            dict[group] = textData.filter { $0.groupIdentifier == group.identifier }
        }
        return dict
    }

    func collectFrames(for textGroup: TextGroup) -> [NSRect] {
        return textData.filter { $0.groupIdentifier == textGroup.identifier }.map { $0.rect }
    }

    // MARK: - ConfigValidatable

    public func validate() throws {
        // TODO: Validate screenshot size compared to template file
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

    public func printSummary(insetByTabs tabs: Int) {
        CommandLineFormatter.printKeyValue("Ouput suffix", value: outputSuffix, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Template file path", value: templateImagePath.absoluteString, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Screenshot folders", value: screenshots.count, insetBy: tabs)
        screenshotData.forEach { $0.printSummary(insetByTabs: tabs) }
        textData.forEach { $0.printSummary(insetByTabs: tabs) }
    }
}
