import Foundation

public struct ScreenshotData: Decodable, ConfigValidatable, Equatable {

    // MARK: - Properties

    let screenshotName: String
    let bottomLeft: Point
    let bottomRight: Point
    let topLeft: Point
    let topRight: Point
    let zIndex: Int?

    // MARK: - Init

    internal init(screenshotName: String, bottomLeft: Point, bottomRight: Point, topLeft: Point, topRight: Point, zIndex: Int?) {
        self.screenshotName = screenshotName
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        self.topLeft = topLeft
        self.topRight = topRight
        self.zIndex = zIndex
    }

    // MARK: - Misc

    func makeProcessedData(size: CGSize) -> ScreenshotData {
        return ScreenshotData(
            screenshotName: screenshotName,
            bottomLeft: bottomLeft.convertingToBottomLeftOrigin(with: size),
            bottomRight: bottomRight.convertingToBottomLeftOrigin(with: size),
            topLeft: topLeft.convertingToBottomLeftOrigin(with: size),
            topRight: topRight.convertingToBottomLeftOrigin(with: size),
            zIndex: zIndex)
    }

    // MARK: - ConfigValidatable

    func validate() throws {}

    func printSummary(insetByTabs tabs: Int) {
        CommandLineFormatter.printKeyValue("Screenshot Name", value: screenshotName, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Bottom Left", value: bottomLeft, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Bottom Right", value: bottomRight, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Top Left", value: topLeft, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Top Right", value: topRight, insetBy: tabs + 1)
        CommandLineFormatter.printKeyValue("Z Index", value: zIndex, insetBy: tabs + 1)
    }
}
