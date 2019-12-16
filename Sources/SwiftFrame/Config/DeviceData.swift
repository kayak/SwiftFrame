import AppKit
import Foundation

struct DeviceData: Decodable, ConfigValidatable {
    let outputSuffix: String
    let screenshotsPath: URL
    let screenshots: [String : [NSImage]]
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
        var parsedScreenshots = [String : [NSImage]]()
        let subDirectories = screenshotsPath.subDirectories
        try subDirectories.forEach { folder in
            let imageFiles = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                .filter { kScreenshotExtensions.contains($0.pathExtension) }
            let images = try imageFiles.map { try ImageLoader().loadImage(atPath: $0.absoluteString) }
            parsedScreenshots[folder.lastPathComponent] = images
        }
        screenshots = parsedScreenshots
    }

    func validate() throws {

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
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    var subDirectories: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.isDirectory }) ?? []
    }
}
