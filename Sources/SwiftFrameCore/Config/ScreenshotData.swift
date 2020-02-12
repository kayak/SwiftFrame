import Foundation

public struct ScreenshotData: Decodable, ConfigValidatable, Equatable {

    // MARK: - Properties

    let screenshotName: String
    let bottomLeft: Point
    let bottomRight: Point
    let topLeft: Point
    let topRight: Point
    private let _zIndex: Int?

    public var zIndex: Int {
        _zIndex ?? 0
    }

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case screenshotName
        case bottomLeft
        case bottomRight
        case topLeft
        case topRight
        case _zIndex = "zIndex"
    }

    // MARK: - Init

    internal init(screenshotName: String, bottomLeft: Point, bottomRight: Point, topLeft: Point, topRight: Point, _zIndex: Int?) {
        self.screenshotName = screenshotName
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        self.topLeft = topLeft
        self.topRight = topRight
        self._zIndex = _zIndex
    }

    // MARK: - Misc

    func makeProcessedData(size: CGSize) -> ScreenshotData {
        return ScreenshotData(
            screenshotName: screenshotName,
            bottomLeft: bottomLeft.convertToBottomLeftOrigin(with: size),
            bottomRight: bottomRight.convertToBottomLeftOrigin(with: size),
            topLeft: topLeft.convertToBottomLeftOrigin(with: size),
            topRight: topRight.convertToBottomLeftOrigin(with: size),
            _zIndex: _zIndex)
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
