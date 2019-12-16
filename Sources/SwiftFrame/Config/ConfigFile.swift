import Foundation
import AppKit

protocol ConfigValidatable {
    func validate() throws
    func printSummary()
}

// First key is locale, second is regular key in string file
typealias LocalizedStringFiles = [String : [String : String]]

public struct ConfigFile: Decodable, ConfigValidatable {
    let deviceData: [DeviceData]
    let titlesPath: URL
    let titles: LocalizedStringFiles
    let maxFontSize: Int
    let outputPaths: [URL]
    let font: NSFont
    let textColor: NSColor

    enum CodingKeys: String, CodingKey {
        case deviceData
        case titlesPath
        case maxFontSize
        case outputPaths
        case fontFile
        case textColor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deviceData = try container.decode([DeviceData].self, forKey: .deviceData)
        maxFontSize = try container.decode(Int.self, forKey: .maxFontSize)
        outputPaths = try container.decode([URL].self, forKey: .outputPaths)

        let fontPathString = try container.decode(String.self, forKey: .fontFile)
        self.font = try fontPathString.registerFont()

        let colorHexString = try container.decode(String.self, forKey: .textColor)
        textColor = try NSColor(hexString: colorHexString)

        titlesPath = try container.decode(URL.self, forKey: .titlesPath)
        var parsedTitles = LocalizedStringFiles()
        let textFiles = try FileManager.default.contentsOfDirectory(at: titlesPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            .filter { $0.pathExtension == "strings" }
        textFiles.forEach { textFile in
            parsedTitles[textFile.lastPathComponent] = NSDictionary(contentsOf: textFile) as? [String: String]
        }
        titles = parsedTitles
    }

    func validate() throws {
        try deviceData.forEach { try $0.validate() }


    }

    func printSummary() {
        print("### Config Summary Begin")
        print(CommandLineFormatter.formatKeyValue("Title Color", value: textColor.hexString))
        print(CommandLineFormatter.formatKeyValue("Title Font", value: font.fontName))
        print(CommandLineFormatter.formatKeyValue("Title Max Font Size", value: maxFontSize))
        print(CommandLineFormatter.formatKeyValue("String Files", value: titles.count))

        print("Output paths:")
        outputPaths.forEach { print("\t" + $0.absoluteString) }

        print("### Device data:")
        deviceData.forEach { $0.printSummary() }
//        print("Title Padding: \(titlePadding)")
//        for (index, element) in screenshotPathsByFrame.enumerated() {
//            print("Frame #\(index + 1) Path: \(element.key.path)")
//            print("Frame #\(index + 1) Viewport: \(element.key.viewport)")
//            print("Frame #\(index + 1) Padding: \(element.key.padding)")
//            for (screenshotIndex, path) in element.value.enumerated() {
//                print("Frame #\(index + 1) Screenshot #\(screenshotIndex + 1): \(path)")
//            }
//        }
        print("### Config Summary End")
    }
}
