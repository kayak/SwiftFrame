import Foundation

public struct ScreenshotData: Decodable, ConfigValidatable {
    public let screenshotName: String
    let bottomLeft: Point
    let bottomRight: Point
    let topLeft: Point
    let topRight: Point
    let zIndex: Int

    enum CodingKeys: String, CodingKey {
        case screenshotName
        case bottomLeft
        case bottomRight
        case topLeft
        case topRight
        case zIndex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.screenshotName = try container.decode(String.self, forKey: .screenshotName)
        self.bottomLeft = try container.decode(Point.self, forKey: .bottomLeft)
        self.bottomRight = try container.decode(Point.self, forKey: .bottomRight)
        self.topLeft = try container.decode(Point.self, forKey: .topLeft)
        self.topRight = try container.decode(Point.self, forKey: .topRight)
        self.zIndex = try container.decodeIfPresent(Int.self, forKey: .zIndex) ?? 0
    }

    public func validate() throws {}

    public func printSummary(insetByTabs tabs: Int) {
        CommandLineFormatter.printKeyValue("Screenshot Name", value: screenshotName, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Bottom Left", value: bottomLeft.formattedString, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Bottom Right", value: bottomRight.formattedString, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Top Left", value: topLeft.formattedString, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Top Right", value: topRight.formattedString, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Z Index", value: zIndex, insetBy: tabs + 1)
    }
}
