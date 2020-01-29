import Foundation
import XCTest
@testable import SwiftFrameCore

class ScreenshotDataTests: XCTestCase {

    func testGoodData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertNoThrow(try ScreenshotDataContainer.makeGoodData())
        try TestingUtility.clearTestingDirectory()
    }

    func testBadData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertThrowsError(try ScreenshotData(from: ScreenshotDataContainer.badData))
        try TestingUtility.clearTestingDirectory()
    }

    func testValidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try ScreenshotDataContainer.makeGoodData()
        XCTAssertNoThrow(try data.validate())

        try TestingUtility.clearTestingDirectory()
    }

    func testInvertedData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try ScreenshotDataContainer.makeInvertedData()
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
