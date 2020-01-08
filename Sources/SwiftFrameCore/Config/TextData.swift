import AppKit
import Foundation

public typealias AssociatedString = (string: String, data: TextData)

public struct TextData: Decodable, ConfigValidatable {
    public let titleIdentifier: String
    let bottomLeft: Point
    let topRight: Point
    public let textAlignment: NSTextAlignment
    /// Text group will be prioritized over this, if specified
    public let maxFontSizeOverride: CGFloat?
    public let customFont: NSFont?
    public let textColorOverride: NSColor?
    public let groupIdentifier: String?

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

    public init(from decoder: Decoder) throws {
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

    public func validate() throws {
        if (bottomLeft.x >= topRight.x) || (bottomLeft.y >= topRight.y) {
            throw NSError(description: "Bad text bounds: \(bottomLeft.formattedString) and \(topRight.formattedString)")
        }
    }

    public func printSummary(insetByTabs tabs: Int) {
        CommandLineFormatter.printKeyValue("Text ID", value: titleIdentifier, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Bottom Left", value: bottomLeft.formattedString, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Top Right", value: topRight.formattedString, insetBy: tabs + 1)

        if let fontName = customFont?.fontName {
            CommandLineFormatter.printKeyValue("Custom font", value: fontName, insetBy: tabs + 1)
        }

        if let ptSize = maxFontSizeOverride {
            CommandLineFormatter.printKeyValue("Max Point Size", value: ptSize, insetBy: tabs + 1)
        }

        if let textColorOverride = textColorOverride {
            CommandLineFormatter.printKeyValue("Custom color", value: textColorOverride.hexString, insetBy: tabs + 1)
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
        case "justify":
            self.init(rawValue: 3)!
        case "natural":
            self.init(rawValue: 4)!
        default:
            throw NSError(description: "Invalid text alignment \"\(alignmentString)\" was parsed")
        }
    }

}
