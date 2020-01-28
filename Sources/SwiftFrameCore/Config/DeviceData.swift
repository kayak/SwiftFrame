import AppKit
import Foundation

let kScreenshotExtensions = Set<String>(arrayLiteral: "png", "jpg", "jpeg")

public final class DeviceData: KYDecodable, ConfigValidatable {

    // MARK: - Properties

    public let outputSuffix: String
    public let screenshots: [String : [String: NSBitmapImageRep]]
    public let templateImage: NSBitmapImageRep
    public private(set) var screenshotData = [ScreenshotData]()
    public private(set) var textData = [TextData]()
    private let screenshotsPath: LocalURL
    private let templateFilePath: LocalURL

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case outputSuffix
        case screenshots
        case templateFile
        case screenshotData
        case textData
        case coordinatesOriginIsTopLeft
    }

    // MARK: - Init

    public init(from json: JSONDictionary) throws {
        templateFilePath = try json.ky_decode(with: CodingKeys.templateFile)
        guard let rep = ImageLoader.loadRepresentation(at: templateFilePath.absoluteURL) else {
            throw NSError(description: "Error while loading template image at path \(templateFilePath.absoluteString)")
        }
        templateImage = rep
        outputSuffix = try json.ky_decode(with: CodingKeys.outputSuffix)
        textData = try json.ky_decode(with: CodingKeys.textData)
        screenshotsPath = try json.ky_decode(with: CodingKeys.screenshots)

        let screenshotData: [ScreenshotData] = try json.ky_decode(with: CodingKeys.screenshotData)
        self.screenshotData = screenshotData.sorted { $0.zIndex < $1.zIndex }

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
        screenshots = parsedScreenshots

        if try json.ky_decode(with: CodingKeys.coordinatesOriginIsTopLeft) {
            convertTextAndScreenshotData()
        }
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        templateFilePath = try container.ky_decode(LocalURL.self, forKey: .templateFile)
        guard let rep = ImageLoader.loadRepresentation(at: templateFilePath.absoluteURL) else {
            throw NSError(description: "Error while loading template image")
        }
        templateImage = rep
        outputSuffix = try container.ky_decode(String.self, forKey: .outputSuffix)
        screenshotData = try container.ky_decode([ScreenshotData].self, forKey: .screenshotData).sorted { $0.zIndex < $1.zIndex }
        textData = try container.ky_decode([TextData].self, forKey: .textData)
        screenshotsPath = try container.ky_decode(LocalURL.self, forKey: .screenshots)

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
        screenshots = parsedScreenshots

        if try container.ky_decode(Bool.self, forKey: .coordinatesOriginIsTopLeft) {
            convertTextAndScreenshotData()
        }
    }

    // MARK: - Methods

    private func convertTextAndScreenshotData() {
        textData = textData.map { $0.convertToBottomLeftOrigin(with: templateImage.size) }
        screenshotData = screenshotData.map { $0.convertToBottomLeftOrigin(with: templateImage.size) }
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
        CommandLineFormatter.printKeyValue("Template file path", value: templateFilePath.absoluteString, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Screenshot folders", value: screenshots.count, insetBy: tabs)
        screenshotData.forEach { $0.printSummary(insetByTabs: tabs) }
        textData.forEach { $0.printSummary(insetByTabs: tabs) }
    }
}
