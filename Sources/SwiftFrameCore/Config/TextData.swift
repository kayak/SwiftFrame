import AppKit
import Foundation

public typealias AssociatedString = (string: String, data: TextData)

public struct TextData: Decodable, ConfigValidatable {

    // MARK: - Properties

    public let titleIdentifier: String
    public let textAlignment: NSTextAlignment
    /// Text group will be prioritized over this, if specified
    public let maxFontSizeOverride: CGFloat?
    public let customFontPath: String?
    public let textColorOverrideString: String?
    public let groupIdentifier: String?
    public let topLeft: Point
    public let bottomRight: Point

    public private(set) var customFont: NSFont?
    public private(set) var textColorOverride: NSColor?

    var rect: NSRect {
        let origin = CGPoint(x: topLeft.x, y: bottomRight.y)
        return NSRect(origin: origin, size: CGSize(width: bottomRight.x - topLeft.x, height: topLeft.y - bottomRight.y))
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case titleIdentifier
        case textColorOverrideString = "textColorOverride"
        case maxFontSizeOverride
        case customFontPath = "customFont"
        case topLeft
        case bottomRight
        case textAlignment
        case groupIdentifier
    }

    // MARK: - Misc

    public func makeProcessedData(originIsTopLeft: Bool, size: CGSize) throws -> TextData {
        let processedTopLeft = originIsTopLeft ? topLeft.convertToBottomLeftOrigin(with: size) : topLeft
        let processedBottomRight = originIsTopLeft ? bottomRight.convertToBottomLeftOrigin(with: size) : bottomRight

        let colorOverride: NSColor?
        if let hex = textColorOverrideString {
            colorOverride = try NSColor(hexString: hex)
        } else {
            colorOverride = nil
        }

        let font: NSFont?
        if let fontPath = customFontPath {
            font = try FontRegistry.shared.registerFont(atPath: fontPath)
        } else {
            font = nil
        }

        return TextData(
            titleIdentifier: titleIdentifier,
            textAlignment: textAlignment,
            maxFontSizeOverride: maxFontSizeOverride,
            customFontPath: customFontPath,
            textColorOverrideString: textColorOverrideString,
            groupIdentifier: groupIdentifier,
            topLeft: processedTopLeft,
            bottomRight: processedBottomRight,
            customFont: font,
            textColorOverride: colorOverride)
    }

    // MARK: - ConfigValidatable

    public func validate() throws {
        if (topLeft.x >= bottomRight.x) || (topLeft.y <= bottomRight.y) {
            throw NSError(description: "Bad text bounds - topLeft: \(topLeft) and bottomRight: \(bottomRight)")
        }
    }

    public func printSummary(insetByTabs tabs: Int) {
        CommandLineFormatter.printKeyValue("Text ID", value: titleIdentifier, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Top Left", value: topLeft, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Bottom Right", value: bottomRight, insetBy: tabs + 1)

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
