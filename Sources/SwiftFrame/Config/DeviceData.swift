import AppKit
import Foundation

let kScreenshotExtensions = Set<String>(arrayLiteral: "png", "jpg", "jpeg")

struct DeviceData: Decodable, ConfigValidatable {
    let outputSuffix: String
    let screenshotsPath: LocalURL
    let screenshots: [String : [String: NSBitmapImageRep]]
    let templateFilePath: LocalURL
    let templateImage: NSBitmapImageRep
    let screenshotData: [ScreenshotData]
    let textData: [TextData]

    enum CodingKeys: String, CodingKey {
        case outputSuffix
        case screenshots
        case templateFile
        case screenshotData
        case textData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        templateFilePath = try container.decode(LocalURL.self, forKey: .templateFile)
        guard let rep = templateFilePath.absoluteURL.bitmapRep else {
            throw NSError(description: "Error while loading template image")
        }
        templateImage = rep
        outputSuffix = try container.decode(String.self, forKey: .outputSuffix)
        screenshotData = try container.decode([ScreenshotData].self, forKey: .screenshotData)
        textData = try container.decode([TextData].self, forKey: .textData)
        screenshotsPath = try container.decode(LocalURL.self, forKey: .screenshots)

        var parsedScreenshots = [String : [String : NSBitmapImageRep]]()
        try screenshotsPath.absoluteURL.subDirectories.forEach { folder in
            let imageFiles = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                .filter { kScreenshotExtensions.contains($0.pathExtension) }
            let imagesDictionary = imageFiles.reduce(into: [String: NSBitmapImageRep]()) { dictionary, url in
                let rep = url.bitmapRep
                dictionary[url.lastPathComponent] = rep
            }
            parsedScreenshots[folder.lastPathComponent] = imagesDictionary
        }
        screenshots = parsedScreenshots
    }

    func validate() throws {
        // TODO: Validate screenshot size compared to template file
        try screenshots.forEach { localeDict in
            guard let first = localeDict.value.first?.value else {
                return
            }
            try localeDict.value.forEach {
                if $0.value.size != first.size {
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

    func printSummary(insetByTabs tabs: Int) {
        print(CommandLineFormatter.formatKeyValue("Ouput suffix", value: outputSuffix, insetBy: tabs))
        print(CommandLineFormatter.formatKeyValue("Template file path", value: templateFilePath.absoluteString, insetBy: tabs))
        print(CommandLineFormatter.formatKeyValue("Screenshot folders", value: screenshots.count, insetBy: tabs))
        screenshotData.forEach { $0.printSummary(insetByTabs: tabs) }
        textData.forEach { $0.printSummary(insetByTabs: tabs) }
    }
}
