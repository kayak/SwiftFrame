import Foundation
import AppKit

public protocol ConfigValidatable {
    func validate() throws
    func printSummary(insetByTabs tabs: Int)
}

/// First key is locale, second is regular key in string file
public typealias LocalizedStringFiles = [String : [String : String]]

public struct ConfigFile: Decodable, ConfigValidatable {

    // MARK: - Properties

    public let outputWholeImage: Bool
    public let deviceData: [DeviceData]
    public let textGroups: [TextGroup]
    public let titlesPath: LocalURL
    public let titles: LocalizedStringFiles
    public let maxFontSize: CGFloat
    public let outputPaths: [LocalURL]
    public let font: NSFont
    public let textColor: NSColor

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case outputWholeImage = "alsoOutputWholeImage"
        case deviceData
        case textGroups
        case titlesPath
        case maxFontSize
        case outputPaths
        case fontFile
        case textColor
    }

    // MARK: - Init

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        outputWholeImage = try container.decodeIfPresent(Bool.self, forKey: .outputWholeImage) ?? false
        deviceData = try container.ky_decode([DeviceData].self, forKey: .deviceData)
        textGroups = try container.decodeIfPresent([TextGroup].self, forKey: .textGroups) ?? []
        maxFontSize = try container.ky_decode(CGFloat.self, forKey: .maxFontSize)
        outputPaths = try container.ky_decode([LocalURL].self, forKey: .outputPaths)

        let fontPathString = try container.ky_decode(String.self, forKey: .fontFile)
        self.font = try FontRegistry.shared.registerFont(atPath: fontPathString)

        let colorHexString = try container.ky_decode(String.self, forKey: .textColor)
        textColor = try NSColor(hexString: colorHexString)

        titlesPath = try container.ky_decode(LocalURL.self, forKey: .titlesPath)
        var parsedTitles = LocalizedStringFiles()
        let textFiles = try FileManager.default.contentsOfDirectory(at: titlesPath.absoluteURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            .filter { $0.pathExtension == "strings" }
        textFiles.forEach { textFile in
            parsedTitles[textFile.absoluteURL.fileName] = NSDictionary(contentsOf: textFile) as? [String: String]
        }
        titles = parsedTitles
    }

    // MARK: - ConfigValidatable

    public func validate() throws {
        guard !deviceData.isEmpty else {
            throw NSError(description: "No screenshot data was supplied")
        }
        try deviceData.forEach { try $0.validate() }
    }

    public func printSummary(insetByTabs tabs: Int) {
        print("### Config Summary Begin")
        CommandLineFormatter.printKeyValue("Outputs whole image as well as slices", value: outputWholeImage)
        CommandLineFormatter.printKeyValue("Title Color", value: textColor.hexString, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Title Font", value: font.fontName, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Title Max Font Size", value: maxFontSize, insetBy: tabs)
        CommandLineFormatter.printKeyValue("String Files", value: titles.count, insetBy: tabs)

        print("Output paths:")
        outputPaths.forEach { print($0.absoluteString.formattedGreen(), insetByTabs: tabs + 1) }

        print("Device data:")
        deviceData.forEach {
            $0.printSummary(insetByTabs: tabs + 1)
            print("")
        }

        if !textGroups.isEmpty {
            print("Text groups:")
            textGroups.forEach {
                $0.printSummary(insetByTabs: tabs + 1)
                print("")
            }
        } else {
            print("No implicit text groups defined, using global max font size\n")
        }

        print("### Config Summary End")
    }
}
