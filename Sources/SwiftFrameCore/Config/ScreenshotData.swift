import Foundation

public struct ScreenshotData: Decodable, ConfigValidatable, Equatable {

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

    // MARK: - Misc

    public func makeProcessedData(originIsTopLeft: Bool, size: CGSize) -> ScreenshotData {
        return ScreenshotData(
            screenshotName: screenshotName,
            bottomLeft: originIsTopLeft ? bottomLeft.convertToBottomLeftOrigin(with: size) : bottomLeft,
            bottomRight: originIsTopLeft ? bottomRight.convertToBottomLeftOrigin(with: size) : bottomRight,
            topLeft: originIsTopLeft ? topLeft.convertToBottomLeftOrigin(with: size) : topLeft,
            topRight: originIsTopLeft ? topRight.convertToBottomLeftOrigin(with: size) : topRight,
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
