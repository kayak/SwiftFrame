import AppKit
import Foundation

private let kNumTitleLines = 3

public struct TextGroup: Codable, JSONDecodable, ConfigValidatable, Hashable {

    // MARK: - Properties

    public let identifier: String
    public let maxFontSize: CGFloat

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case identifier
        case maxFontSize
    }

    // MARK: - Init

    public init(from json: JSONDictionary) throws {
        identifier = try json.ky_decode(with: CodingKeys.identifier)
        maxFontSize = try json.ky_decode(with: CodingKeys.maxFontSize)
    }

    // MARK: - ConfigValidatable

    public func validate() throws {}

    public func printSummary(insetByTabs tabs: Int) {
        print("Text group: \(identifier)", insetByTabs: tabs)
        CommandLineFormatter.printKeyValue("Identifier", value: identifier, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Max font size", value: maxFontSize, insetBy: tabs + 1)
    }

    // MARK: - Misc

    public func sharedFontSize(with strings: [AssociatedString], globalFont: NSFont, globalMaxSize: CGFloat) -> CGFloat {
        let textRenderer = TextRenderer()
        let maxFontSizes: [CGFloat] = strings.compactMap {
            do {
                return try textRenderer.maximumFontSizeThatFits(
                    string: $0.string,
                    font: $0.data.customFont ?? globalFont,
                    alignment: $0.data.textAlignment,
                    maxSize: $0.data.maxFontSizeOverride ?? globalMaxSize,
                    size: $0.data.rect.size)
            } catch {
                return nil
            }
        }
        // Can force-unwrap since array will never be empty
        return ([globalMaxSize, maxFontSize] + maxFontSizes).min()!
    }
}
