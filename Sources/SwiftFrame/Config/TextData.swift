import AppKit
import Foundation

typealias AssociatedString = (string: String, data: TextData, maxFontSize: CGFloat)

struct TextData: Decodable, ConfigValidatable {
    let titleIdentifier: String
    let bottomLeft: Point
    let topRight: Point
    let textAlignment: NSTextAlignment
    /// Text group will be prioritized over this, if specified
    let maxFontSizeOverride: CGFloat?
    let customFont: NSFont?
    let textColorOverride: NSColor?
    let groupIdentifier: String?

    var rect: NSRect {
        NSRect(origin: bottomLeft.cgPoint, size: CGSize(width: topRight.x - bottomLeft.x, height: topRight.y - bottomLeft.y))
    }

    enum CodingKeys: String, CodingKey {
        case titleIdentifier
        case textColorOverride
        case maxFontSizeOverride
        case customFont = "customFontPath"
        case bottomLeft
        case topRight
        case textAlignment
        case groupIdentifier
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titleIdentifier = try container.decode(String.self, forKey: .titleIdentifier)
        bottomLeft = try container.decode(Point.self, forKey: .bottomLeft)
        topRight = try container.decode(Point.self, forKey: .topRight)
        textAlignment = try container.decode(NSTextAlignment.self, forKey: .textAlignment)
        maxFontSizeOverride = try container.decodeIfPresent(CGFloat.self, forKey: .maxFontSizeOverride)
        groupIdentifier = try container.decodeIfPresent(String.self, forKey: .groupIdentifier)

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
        if (bottomLeft.x >= topRight.x) || (bottomLeft.y >= topRight.y) {
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

extension NSTextAlignment: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let alignmentString = try container.decode(String.self)
        switch alignmentString {
        case "left":
            self.init(rawValue: 0)!
        case "right":
            self.init(rawValue: 1)!
        case "center":
            self.init(rawValue: 2)!
        case "justified":
            self.init(rawValue: 3)!
        case "natural":
            self.init(rawValue: 4)!
        default:
            throw NSError(description: "Invalid text alignment \"\(alignmentString)\" was parsed")
        }
    }

}
