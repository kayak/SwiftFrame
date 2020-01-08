import AppKit
import Foundation

let kScreenshotExtensions = Set<String>(arrayLiteral: "png", "jpg", "jpeg")

public struct DeviceData: Decodable, ConfigValidatable {
    public let outputSuffix: String
    let screenshotsPath: LocalURL
    public let screenshots: [String : [String: NSBitmapImageRep]]
    let templateFilePath: LocalURL
    public let templateImage: NSBitmapImageRep
    public let screenshotData: [ScreenshotData]
    public let textData: [TextData]

    enum CodingKeys: String, CodingKey {
        case outputSuffix
        case screenshots
        case templateFile
        case screenshotData
        case textData
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        templateFilePath = try container.decode(LocalURL.self, forKey: .templateFile)
        guard let rep = templateFilePath.absoluteURL.bitmapRep else {
            throw NSError(description: "Error while loading template image")
        }
        templateImage = rep
        outputSuffix = try container.decode(String.self, forKey: .outputSuffix)
        screenshotData = try container.decode([ScreenshotData].self, forKey: .screenshotData).sorted { $0.zIndex < $1.zIndex }
        textData = try container.decode([TextData].self, forKey: .textData)
        screenshotsPath = try container.decode(LocalURL.self, forKey: .screenshots)

        var parsedScreenshots = [String : [String : NSBitmapImageRep]]()
        try screenshotsPath.absoluteURL.subDirectories.forEach { folder in
            let imageFiles = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                .filter { kScreenshotExtensions.contains($0.pathExtension.lowercased()) }
            let imagesDictionary = imageFiles.reduce(into: [String: NSBitmapImageRep]()) { dictionary, url in
                let rep = url.bitmapRep
                dictionary[url.lastPathComponent] = rep
            }
            parsedScreenshots[folder.lastPathComponent] = imagesDictionary
        }
        screenshots = parsedScreenshots
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
