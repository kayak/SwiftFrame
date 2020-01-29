import Foundation
import XCTest
@testable import SwiftFrameCore

class TextDataTests: XCTestCase {

    func testGoodData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertNoThrow(try TextDataMock.makeGoodData())
        try TestingUtility.clearTestingDirectory()
    }

    func testBadData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertThrowsError(try TextData(from: TextDataMock.badData))
        try TestingUtility.clearTestingDirectory()
    }

    func testValidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try TextDataMock.makeGoodData()
        XCTAssertNoThrow(try data.validate())

        try TestingUtility.clearTestingDirectory()
    }

    func testInvalidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try TextDataMock.makeInvalidData()
        XCTAssertThrowsError(try data.validate())

        try TestingUtility.clearTestingDirectory()
    }

    func testInvertedData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try TextDataMock.makeInvertedData()
        XCTAssertThrowsError(try data.validate())

        try TestingUtility.clearTestingDirectory()
    }

    func testConvertingOrigin() throws {
        let textData = try TextData(from: TextDataMock.goodData)
        let size = CGSize(width: 40, height: 60)
        let convertedData = textData.convertToBottomLeftOrigin(with: size)

        XCTAssertEqual(convertedData.topLeft, Point(x: 10, y: 40))
    }

}
