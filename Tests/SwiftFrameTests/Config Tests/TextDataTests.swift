import Foundation
import XCTest
@testable import SwiftFrameCore

class TextDataTests: XCTestCase {

    func testValidData() throws {
        XCTAssertNoThrow(try TextData.goodData.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvalidData() throws {
        XCTAssertThrowsError(try TextData.invalidData.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvertedData() throws {
        XCTAssertThrowsError(try TextData.invertedData.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testConvertingOrigin() throws {
        let textData = TextData.goodData
        let size = CGSize(width: 40, height: 60)
        let convertedData = try textData.makeProcessedData(originIsTopLeft: true, size: size)

        XCTAssertEqual(convertedData.topLeft, Point(x: 10, y: 40))
    }

}
