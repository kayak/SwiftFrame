import Foundation
import AppKit

protocol ConfigValidatable {
    func validate() throws
    func printSummary(insetByTabs tabs: Int)
}

// First key is locale, second is regular key in string file
typealias LocalizedStringFiles = [String : [String : String]]

public struct ConfigFile: Decodable, ConfigValidatable {
    let outputWholeImage: Bool
    let deviceData: [DeviceData]
    let titlesPath: LocalURL
    let titles: LocalizedStringFiles
    let maxFontSize: Int
    let outputPaths: [LocalURL]
    let font: NSFont
    let textColor: NSColor

    enum CodingKeys: String, CodingKey {
        case outputWholeImage = "alsoOutputWholeImage"
        case deviceData
        case titlesPath
        case maxFontSize
        case outputPaths
        case fontFile
        case textColor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        outputWholeImage = try container.decodeIfPresent(Bool.self, forKey: .outputWholeImage) ?? false
        deviceData = try container.decode([DeviceData].self, forKey: .deviceData)
        maxFontSize = try container.decode(Int.self, forKey: .maxFontSize)
        outputPaths = try container.decode([LocalURL].self, forKey: .outputPaths)

        let fontPathString = try container.decode(String.self, forKey: .fontFile)
        self.font = try fontPathString.registerFont()

        let colorHexString = try container.decode(String.self, forKey: .textColor)
        textColor = try NSColor(hexString: colorHexString)

        titlesPath = try container.decode(LocalURL.self, forKey: .titlesPath)
        var parsedTitles = LocalizedStringFiles()
        let textFiles = try FileManager.default.contentsOfDirectory(at: titlesPath.absoluteURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            .filter { $0.pathExtension == "strings" }
        textFiles.forEach { textFile in
            parsedTitles[textFile.lastPathComponent] = NSDictionary(contentsOf: textFile) as? [String: String]
        }
        titles = parsedTitles
    }

    func validate() throws {
        try deviceData.forEach { try $0.validate() }
    }

    func printSummary(insetByTabs tabs: Int) {
        print("### Config Summary Begin")
        print(CommandLineFormatter.formatKeyValue("Outputs whole image as well as slices", value: outputWholeImage))
        print(CommandLineFormatter.formatKeyValue("Title Color", value: textColor.hexString, insetBy: tabs))
        print(CommandLineFormatter.formatKeyValue("Title Font", value: font.fontName, insetBy: tabs))
        print(CommandLineFormatter.formatKeyValue("Title Max Font Size", value: maxFontSize, insetBy: tabs))
        print(CommandLineFormatter.formatKeyValue("String Files", value: titles.count, insetBy: tabs))

        print("Output paths:")
        outputPaths.forEach { print(String(repeating: "\t", count: tabs + 1) + $0.absoluteString.formattedGreen()) }

        print("Device data:")
        deviceData.forEach {
            $0.printSummary(insetByTabs: tabs + 1)
            print("")
        }
        print("### Config Summary End")
    }
}
