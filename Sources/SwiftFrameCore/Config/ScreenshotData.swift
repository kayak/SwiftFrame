import Foundation

public struct ScreenshotData: Decodable, ConfigValidatable, Equatable {

    // MARK: - Properties

    public let screenshotName: String
    public let bottomLeft: Point
    public let bottomRight: Point
    public let topLeft: Point
    public let topRight: Point
    private let z_Index: Int?

    public var zIndex: Int {
        z_Index ?? 0
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case screenshotName
        case bottomLeft
        case bottomRight
        case topLeft
        case topRight
        case z_Index = "zIndex"
    }

    // MARK: - Init

    public init(screenshotName: String, bottomLeft: Point, bottomRight: Point, topLeft: Point, topRight: Point, zIndex: Int? = nil) {
        self.screenshotName = screenshotName
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        self.topLeft = topLeft
        self.topRight = topRight
        self.z_Index = zIndex ?? 0
    }

    // MARK: - Misc

    public func makeProcessedData(size: CGSize) -> ScreenshotData {
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
