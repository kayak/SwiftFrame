import AppKit
import Foundation

public struct TextGroup: Codable, Hashable {

    // MARK: - Properties

    let identifier: String
    let maxFontSize: CGFloat

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case identifier
        case maxFontSize
    }

    // MARK: - Misc

    func sharedFontSize(with strings: [AssociatedString], globalFont: NSFont, globalMaxSize: CGFloat) throws -> CGFloat {
        let textRenderer = TextRenderer()
        let maxFontSizes: [CGFloat] = try strings.compactMap {
            return try textRenderer.maximumFontSizeThatFits(
                string: $0.string,
                font: $0.data.fontOverride?.font() ?? globalFont,
                alignment: $0.data.textAlignment,
                maxSize: $0.data.maxFontSizeOverride ?? globalMaxSize,
                size: $0.data.rect.size)
        }
        // Can force-unwrap since array will never be empty
        return ([globalMaxSize, maxFontSize] + maxFontSizes).min()!
    }
}

// MARK: - ConfigValidatable

extension TextGroup: ConfigValidatable {

    func validate() throws {}

    func printSummary(insetByTabs tabs: Int) {
        ky_print("Text group: \(identifier)", insetByTabs: tabs)
        CommandLineFormatter.printKeyValue("Identifier", value: identifier, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Max font size", value: maxFontSize, insetBy: tabs + 1)
    }

}

// MARK: - ConfigCreatable

extension TextGroup: ConfigCreatable {

    static func makeTemplate() -> TextGroup {
        TextGroup(identifier: "some_textgroup_id", maxFontSize: 120)
    }

}
