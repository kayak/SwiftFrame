import AppKit
import Foundation

struct TextData: Decodable, ConfigValidatable {
    let titleIdentifier: String
    let bottomLeft: Point
    let topRight: Point
    let maxFontSizeOverride: Int?
    let customFont: NSFont?
    let textColorOverride: NSColor?

    enum CodingKeys: String, CodingKey {
        case titleIdentifier
        case textColorOverride
        case maxFontSizeOverride
        case customFont = "customFontPath"
        case bottomLeft
        case topRight
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titleIdentifier = try container.decode(String.self, forKey: .titleIdentifier)
        bottomLeft = try container.decode(Point.self, forKey: .bottomLeft)
        topRight = try container.decode(Point.self, forKey: .topRight)
        maxFontSizeOverride = try container.decodeIfPresent(Int.self, forKey: .maxFontSizeOverride)

        if let customFontPathString = try container.decodeIfPresent(String.self, forKey: .customFont) {
            customFont = try customFontPathString.registerFont()
        } else {
            customFont = nil
        }

        if let hexString = try container.decodeIfPresent(String.self, forKey: .textColorOverride) {
            textColorOverride = try NSColor(hexString: hexString)
        } else {
            textColorOverride = nil
        }
    }

    func validate() throws {
        if (bottomLeft.x >= topRight.x) || (bottomLeft.y <= topRight.y) {
            throw NSError(description: "Bad text bounds: \(bottomLeft.formattedString) and \(topRight.formattedString)")
        }
    }

    func printSummary(insetByTabs tabs: Int) {
        print(CommandLineFormatter.formatKeyValue("Text ID", value: titleIdentifier, insetBy: tabs))
        print(CommandLineFormatter.formatKeyValue("Bottom Left", value: bottomLeft.formattedString, insetBy: tabs + 1))
        print(CommandLineFormatter.formatKeyValue("Top Right", value: topRight.formattedString, insetBy: tabs + 1))

        if let fontName = customFont?.fontName {
            print(CommandLineFormatter.formatKeyValue("Custom font", value: fontName, insetBy: tabs + 1))
        }

        if let ptSize = maxFontSizeOverride {
            print(CommandLineFormatter.formatKeyValue("Max Point Size", value: ptSize, insetBy: tabs + 1))
        }

        if let textColorOverride = textColorOverride {
            print(CommandLineFormatter.formatKeyValue("Custom color", value: textColorOverride.hexString, insetBy: tabs + 1))
        }
    }
}
