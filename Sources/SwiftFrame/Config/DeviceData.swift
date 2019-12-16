import Foundation

struct DeviceData: Decodable, ConfigValidatable {
    let outputSuffix: String
    let screenshotsPath: URL
    let screenshots: [String : [URL]]
    let templateFile: URL
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
        templateFile = try container.decode(URL.self, forKey: .templateFile)
        screenshotData = try container.decode([ScreenshotData].self, forKey: .screenshotData)
        textData = try container.decode([TextData].self, forKey: .textData)

        screenshotsPath = try container.decode(URL.self, forKey: .screenshots)
        var parsedScreenshots = [String : [URL]]()
        let subDirectories = screenshotsPath.subDirectories
        try subDirectories.forEach { folder in
            let imageFiles = try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
                .filter { kScreenshotExtensions.contains($0.pathExtension) }
            parsedScreenshots[folder.lastPathComponent] = imageFiles
        }
        screenshots = parsedScreenshots
    }

    func validate() throws {

    }

    func printSummary() {
        print("Ouput suffix: \(outputSuffix)")
        //print("Screenshots folder: \(screenshots.absoluteString)")
        print("Template file path: \(templateFile.absoluteString)")
        print("Screenshot folders: \(screenshots.count)")
        screenshotData.forEach { $0.printSummary() }
        textData.forEach { $0.printSummary() }
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
