import Foundation
import XCTest
@testable import SwiftFrameCore

class ScreenshotDataTests: XCTestCase {

    func testGoodData() throws {
        XCTAssertNoThrow(try ScreenshotDataMock.makeGoodData())
        try TestingUtility.clearTestingDirectory()
    }

    func testBadData() throws {
        XCTAssertThrowsError(try ScreenshotData(from: ScreenshotDataMock.badData))
        try TestingUtility.clearTestingDirectory()
    }

    func testValidData() throws {
        let data = try ScreenshotDataMock.makeGoodData()

        XCTAssertNoThrow(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvertedData() throws {
        let data = try ScreenshotDataMock.makeInvertedData()

        XCTAssertNoThrow(try data.validate())
        try TestingUtility.clearTestingDirectory()
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
