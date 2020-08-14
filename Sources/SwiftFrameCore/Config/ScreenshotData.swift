import Foundation

public struct ScreenshotData: Codable, Equatable {

    // MARK: - Properties

    let screenshotName: String
    let bottomLeft: Point
    let bottomRight: Point
    let topLeft: Point
    let topRight: Point

    @DecodableDefault.IntZero var zIndex: Int

    // MARK: - Init

    internal init(screenshotName: String, bottomLeft: Point, bottomRight: Point, topLeft: Point, topRight: Point, zIndex: Int?) {
        self.screenshotName = screenshotName
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        self.topLeft = topLeft
        self.topRight = topRight
        self.zIndex = zIndex ?? 0
    }

    // MARK: - Misc

    func makeProcessedData(size: CGSize) -> ScreenshotData {
        return ScreenshotData(
            screenshotName: screenshotName,
            bottomLeft: bottomLeft.convertingToBottomLeftOrigin(withSize: size),
            bottomRight: bottomRight.convertingToBottomLeftOrigin(withSize: size),
            topLeft: topLeft.convertingToBottomLeftOrigin(withSize: size),
            topRight: topRight.convertingToBottomLeftOrigin(withSize: size),
            zIndex: zIndex)
    }

}

// MARK: - ConfigValidatable

extension ScreenshotData: ConfigValidatable {

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

// MARK: - ConfigCreatable

extension ScreenshotData: ConfigCreatable {

    static func makeTemplate() -> Self {
        ScreenshotData(
            screenshotName: "screenshot_identifier",
            bottomLeft: Point(x: 10, y: 10),
            bottomRight: Point(x: 60, y: 5),
            topLeft: Point(x: 9, y: 200),
            topRight: Point(x: 70, y: 180),
            zIndex: 0
        )
    }

}
