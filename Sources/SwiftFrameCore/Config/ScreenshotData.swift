import Foundation

public struct ScreenshotData: KYDecodable, ConfigValidatable, Equatable {

    // MARK: - Properties

    public let screenshotName: String
    public let bottomLeft: Point
    public let bottomRight: Point
    public let topLeft: Point
    public let topRight: Point
    public let zIndex: Int

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case screenshotName
        case bottomLeft
        case bottomRight
        case topLeft
        case topRight
        case zIndex
    }

    // MARK: - Init

    public init(from json: JSONDictionary) throws {
        self.screenshotName = try json.ky_decode(with: CodingKeys.screenshotName)
        self.bottomLeft = try json.ky_decode(with: CodingKeys.bottomLeft)
        self.bottomRight = try json.ky_decode(with: CodingKeys.bottomRight)
        self.topLeft = try json.ky_decode(with: CodingKeys.topLeft)
        self.topRight = try json.ky_decode(with: CodingKeys.topRight)
        self.zIndex = try json.ky_decodeIfPresent(with: CodingKeys.zIndex) ?? 0
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.screenshotName = try container.ky_decode(String.self, forKey: .screenshotName)
        self.bottomLeft = try container.ky_decode(Point.self, forKey: .bottomLeft)
        self.bottomRight = try container.ky_decode(Point.self, forKey: .bottomRight)
        self.topLeft = try container.ky_decode(Point.self, forKey: .topLeft)
        self.topRight = try container.ky_decode(Point.self, forKey: .topRight)
        self.zIndex = try container.ky_decodeIfPresent(Int.self, forKey: .zIndex) ?? 0
    }

    internal init(screenshotName: String, bottomLeft: Point, bottomRight: Point, topLeft: Point, topRight: Point, zIndex: Int? = 0) {
        self.screenshotName = screenshotName
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        self.topLeft = topLeft
        self.topRight = topRight
        self.zIndex = zIndex ?? 0
    }

    // MARK: - Misc

    public func convertToBottomLeftOrigin(with size: CGSize) -> ScreenshotData {
        return ScreenshotData(
            screenshotName: screenshotName,
            bottomLeft: bottomLeft.convertToBottomLeftOrigin(with: size),
            bottomRight: bottomRight.convertToBottomLeftOrigin(with: size),
            topLeft: topLeft.convertToBottomLeftOrigin(with: size),
            topRight: topRight.convertToBottomLeftOrigin(with: size),
            zIndex: zIndex)
    }

    // MARK: - ConfigValidatable

    public func validate() throws {}

    public func printSummary(insetByTabs tabs: Int) {
        CommandLineFormatter.printKeyValue("Screenshot Name", value: screenshotName, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Bottom Left", value: bottomLeft, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Bottom Right", value: bottomRight, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Top Left", value: topLeft, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Top Right", value: topRight, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Z Index", value: zIndex, insetBy: tabs + 1)
    }
}
