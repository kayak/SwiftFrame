import AppKit
import Foundation

let kScreenshotExtensions = Set<String>(arrayLiteral: "png", "jpg", "jpeg")

struct DeviceData: Decodable, ConfigValidatable {
    let outputSuffix: String
    let screenshotsPath: URL
    let screenshots: [String : [String: NSImage]]
    let templateFilePath: URL
    let templateImage: NSImage
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
        outputSuffix = try container.decode(String.self, forKey: .outputSuffix)
        templateFilePath = try container.decode(URL.self, forKey: .templateFile)
        templateImage = try ImageLoader().loadImage(atPath: templateFilePath.absoluteString)
        screenshotData = try container.decode([ScreenshotData].self, forKey: .screenshotData)
        textData = try container.decode([TextData].self, forKey: .textData)

        screenshotsPath = try container.decode(URL.self, forKey: .screenshots)
        var parsedScreenshots = [String : [String : NSImage]]()
        try screenshotsPath.subDirectories.forEach { folder in
            let imageFiles = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                .filter { kScreenshotExtensions.contains($0.pathExtension) }
            let imagesDictionary = try imageFiles.reduce(into: [String: NSImage]()) { dictionary, url in
                dictionary[url.lastPathComponent] = try ImageLoader().loadImage(atURL: url)
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
                    throw NSError(description: "Screenshot folder \(localeDict.key) does not contain a screenshot named \(name)")
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

extension URL {
    var subDirectories: [URL] {
        guard hasDirectoryPath else {
            print("is not directory")
            return []
        }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.hasDirectoryPath }) ?? []
    }
}
