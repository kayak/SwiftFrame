import Foundation
import AppKit

public protocol ConfigValidatable {
    func validate() throws
    func printSummary(insetByTabs tabs: Int)
}

public protocol JSONDecodable {
    init(from json: JSONDictionary) throws
}

/// First key is locale, second is regular key in string file
public typealias LocalizedStringFiles = [String : [String : String]]
public typealias JSONDictionary = [String : Any]
public typealias KYDecodable = Decodable & JSONDecodable

public struct ConfigData: Decodable, ConfigValidatable {

    // MARK: - Properties

    public let outputWholeImage: Bool
    public let textGroups: [TextGroup]?
    public let titlesPath: LocalURL
    public let maxFontSize: CGFloat
    public let outputPaths: [LocalURL]
    public let fontPath: String
    public let textColorString: String

    public private(set) var deviceData: [DeviceData]
    public private(set) var font: NSFont!
    public private(set) var textColor: NSColor!
    public private(set) var titles = LocalizedStringFiles()

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case outputWholeImage = "alsoOutputWholeImage"
        case deviceData
        case textGroups
        case titlesPath
        case maxFontSize
        case outputPaths
        case fontPath = "fontFile"
        case textColorString = "textColor"
    }

    // MARK: - Processing

    mutating public func process() throws {
        deviceData = try deviceData.map { try $0.makeProcessedData() }

        font = try FontRegistry.shared.registerFont(atPath: fontPath)
        textColor = try NSColor(hexString: textColorString)

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

        if let groups = textGroups, !groups.isEmpty {
            print("Text groups:")
            groups.forEach {
                $0.printSummary(insetByTabs: tabs + 1)
                print("")
            }
        } else {
            print("No implicit text groups defined, using global max font size\n")
        }

        print("### Config Summary End")
    }
}
