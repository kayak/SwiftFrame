import AppKit
import Foundation

typealias AssociatedString = (string: String, data: TextData)

struct TextData: Codable {

    // MARK: - Properties

    let titleIdentifier: String
    let textAlignment: TextAlignment
    /// Text group will be prioritized over this, if specified
    let maxFontSizeOverride: CGFloat?
    let fontOverride: FontSource?
    let textColorOverrideString: String?
    let groupIdentifier: String?
    let topLeft: Point
    let bottomRight: Point

    internal private(set) var textColorOverride: NSColor?

    var rect: NSRect {
        let origin = CGPoint(x: topLeft.x, y: bottomRight.y)
        return NSRect(origin: origin, size: CGSize(width: bottomRight.x - topLeft.x, height: topLeft.y - bottomRight.y))
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case titleIdentifier = "identifier"
        case textColorOverrideString = "colorOverride"
        case maxFontSizeOverride
        case fontOverride = "customFontPath"
        case topLeft
        case bottomRight
        case textAlignment = "alignment"
        case groupIdentifier
    }

    // MARK: - Init

    internal init(
        titleIdentifier: String,
        textAlignment: TextAlignment,
        maxFontSizeOverride: CGFloat? = nil,
        fontOverride: FontSource? = nil,
        textColorOverrideString: String? = nil,
        groupIdentifier: String? = nil,
        topLeft: Point,
        bottomRight: Point,
        textColorOverride: NSColor? = nil)
    {
        self.titleIdentifier = titleIdentifier
        self.textAlignment = textAlignment
        self.maxFontSizeOverride = maxFontSizeOverride
        self.fontOverride = fontOverride
        self.textColorOverrideString = textColorOverrideString
        self.groupIdentifier = groupIdentifier
        self.topLeft = topLeft
        self.bottomRight = bottomRight
        self.textColorOverride = textColorOverride
    }

    // MARK: - Misc

    func makeProcessedData(size: CGSize) throws -> TextData {
        let processedTopLeft = topLeft.convertingToBottomLeftOrigin(withSize: size)
        let processedBottomRight = bottomRight.convertingToBottomLeftOrigin(withSize: size)
        let colorOverride = try textColorOverrideString.flatMap { try NSColor(hexString: $0) }

        return TextData(
            titleIdentifier: titleIdentifier,
            textAlignment: textAlignment,
            maxFontSizeOverride: maxFontSizeOverride,
            fontOverride: fontOverride,
            textColorOverrideString: textColorOverrideString,
            groupIdentifier: groupIdentifier,
            topLeft: processedTopLeft,
            bottomRight: processedBottomRight,
            textColorOverride: colorOverride
        )
    }

}

// MARK: - ConfigValidatable

extension TextData: ConfigValidatable {

    func validate() throws {
        guard (topLeft.x < bottomRight.x) && (topLeft.y > bottomRight.y) else {
            throw NSError(
                description: "Bad text bounds for identifier \"\(titleIdentifier)\"",
                expectation: "Top Left coordinates should have smaller x coordinates and smaller y coordinates than bottom right",
                actualValue: "Top Left: \(topLeft), Bottom Right: \(bottomRight)")
        }
    }

    func printSummary(insetByTabs tabs: Int) {
        CommandLineFormatter.printKeyValue("Text ID", value: titleIdentifier, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Top Left", value: topLeft, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Bottom Right", value: bottomRight, insetBy: tabs + 1)

        if let fontName = try? fontOverride?.font().fontName {
            CommandLineFormatter.printKeyValue("Custom font", value: fontName, insetBy: tabs + 1)
        }

        if let ptSize = maxFontSizeOverride {
            CommandLineFormatter.printKeyValue("Max Point Size", value: ptSize, insetBy: tabs + 1)
        }

        if let textColorOverride = textColorOverride {
            CommandLineFormatter.printKeyValue("Custom color", value: textColorOverride.ky_hexString, insetBy: tabs + 1)
        }
    }

}

// MARK: - ConfigCreatable

extension TextData: ConfigCreatable {

    static func makeTemplate() -> Self {
        TextData(
            titleIdentifier: "some_title_id",
            textAlignment: .init(horizontal: .center, vertical: .top),
            textColorOverrideString: "#4F4F4F",
            groupIdentifier: nil,
            topLeft: Point(x: 20, y: 30),
            bottomRight: Point(x: 74, y: 11)
        )
    }

}
