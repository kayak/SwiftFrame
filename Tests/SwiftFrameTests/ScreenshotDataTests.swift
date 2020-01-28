import Foundation
import XCTest
@testable import SwiftFrameCore

class ScreenshotDataTests: XCTestCase {

    func testGoodData() {
        XCTAssertNoThrow(try ScreenshotData(from: ScreenshotDataContainer.goodData))
    }

    func testBadData() {
        XCTAssertThrowsError(try ScreenshotData(from: ScreenshotDataContainer.badData))
    }

    func testOriginConversion() throws {
        let size = CGSize(width: 100, height: 210)
        let data = ScreenshotData(
            screenshotName: "some_identifier",
            bottomLeft: Point(x: 10, y: 200),
            bottomRight: Point(x: 40, y: 200),
            topLeft: Point(x: 10, y: 10),
            topRight: Point(x: 40, y: 10),
            zIndex: 3)

        let convertedData = data.convertToBottomLeftOrigin(with: size)
        XCTAssertEqual(convertedData.convertToBottomLeftOrigin(with: size), data)
    }

}
