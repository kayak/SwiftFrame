import AppKit
import Foundation

private let kNumTitleLines = 3

public struct TextGroup: Codable, ConfigValidatable, Hashable {
    public let identifier: String
    public let maxFontSize: CGFloat

    public func validate() throws {}

    public func printSummary(insetByTabs tabs: Int) {
        print("Text group: \(identifier)", insetByTabs: tabs)
        CommandLineFormatter.printKeyValue("Identifier", value: identifier, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Max font size", value: maxFontSize, insetBy: tabs + 1)
    }

    public func sharedFontSize(with strings: [AssociatedString], globalFont: NSFont, globalMaxSize: CGFloat) -> CGFloat {
        let textRenderer = TextRenderer()
        let maxFontSizes: [CGFloat] = strings.compactMap {
            do {
                return try textRenderer.maximumFontSizeThatFits(
                    string: $0.string,
                    size: $0.data.rect.size,
                    font: $0.data.customFont ?? globalFont,
                    maxFontSize: $0.data.maxFontSizeOverride ?? globalMaxSize)
            } catch {
                return nil
            }
        }
        // Can force-unwrap since array will never be empty
        return ([globalMaxSize, maxFontSize] + maxFontSizes).min()!
    }
}
