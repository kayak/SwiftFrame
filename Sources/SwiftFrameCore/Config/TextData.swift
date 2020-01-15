import AppKit
import Foundation

public typealias AssociatedString = (string: String, data: TextData)

public struct TextData: Decodable, ConfigValidatable {

    // MARK: - Properties

    public let titleIdentifier: String
    public let textAlignment: NSTextAlignment
    /// Text group will be prioritized over this, if specified
    public let maxFontSizeOverride: CGFloat?
    public let customFont: NSFont?
    public let textColorOverride: NSColor?
    public let groupIdentifier: String?
    private let topLeft: Point
    private let bottomRight: Point

    var rect: NSRect {
        let origin = CGPoint(x: topLeft.x, y: bottomRight.y)
        return NSRect(origin: origin, size: CGSize(width: bottomRight.x - topLeft.x, height: topLeft.y - bottomRight.y))
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case titleIdentifier
        case textColorOverride
        case maxFontSizeOverride
        case customFont = "customFontPath"
        case topLeft
        case bottomRight
        case textAlignment
        case groupIdentifier
    }

    // MARK: - Init

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titleIdentifier = try container.ky_decode(String.self, forKey: .titleIdentifier)
        topLeft = try container.ky_decode(Point.self, forKey: .topLeft)
        bottomRight = try container.ky_decode(Point.self, forKey: .bottomRight)
        textAlignment = try container.ky_decode(NSTextAlignment.self, forKey: .textAlignment)
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

    private init(
        titleIdentifier: String,
        textAlignment: NSTextAlignment,
        maxFontSizeOverride: CGFloat?,
        customFont: NSFont?,
        textColorOverride: NSColor?,
        groupIdentifier: String?,
        topLeft: Point,
        bottomRight: Point)
    {
        self.titleIdentifier = titleIdentifier
        self.textAlignment = textAlignment
        self.maxFontSizeOverride = maxFontSizeOverride
        self.customFont = customFont
        self.textColorOverride = textColorOverride
        self.groupIdentifier = groupIdentifier
        self.topLeft = topLeft
        self.bottomRight = bottomRight
    }

    // MARK: - Misc

    public func convertToBottomLeftOrigin(with size: CGSize) -> TextData {
        return TextData(
            titleIdentifier: titleIdentifier,
            textAlignment: textAlignment,
            maxFontSizeOverride: maxFontSizeOverride,
            customFont: customFont,
            textColorOverride: textColorOverride,
            groupIdentifier: groupIdentifier,
            topLeft: topLeft.convertToBottomLeftOrigin(with: size),
            bottomRight: bottomRight.convertToBottomLeftOrigin(with: size))
    }

    // MARK: - ConfigValidatable

    public func validate() throws {
        if (topLeft.x >= bottomRight.x) || (topLeft.y <= bottomRight.y) {
            throw NSError(description: "Bad text bounds: topLeft\(topLeft.formattedString) and bottomRight\(bottomRight.formattedString)")
        }
    }

    public func printSummary(insetByTabs tabs: Int) {
        CommandLineFormatter.printKeyValue("Text ID", value: titleIdentifier, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Top Left", value: topLeft.formattedString, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Bottom Right", value: bottomRight.formattedString, insetBy: tabs + 1)

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
