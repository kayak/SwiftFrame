import Foundation

public struct ScreenshotData: Decodable, ConfigValidatable {

    // MARK: - Properties

    public let screenshotName: String
    internal let bottomLeft: Point
    internal let bottomRight: Point
    internal let topLeft: Point
    internal let topRight: Point
    internal let zIndex: Int

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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.screenshotName = try container.ky_decode(String.self, forKey: .screenshotName)
        self.bottomLeft = try container.ky_decode(Point.self, forKey: .bottomLeft)
        self.bottomRight = try container.ky_decode(Point.self, forKey: .bottomRight)
        self.topLeft = try container.ky_decode(Point.self, forKey: .topLeft)
        self.topRight = try container.ky_decode(Point.self, forKey: .topRight)
        self.zIndex = try container.ky_decodeIfPresent(Int.self, forKey: .zIndex) ?? 0
    }

    internal init(screenshotName: String, bottomLeft: Point, bottomRight: Point, topLeft: Point, topRight: Point, zIndex: Int) {
        self.screenshotName = screenshotName
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        self.topLeft = topLeft
        self.topRight = topRight
        self.zIndex = zIndex
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
