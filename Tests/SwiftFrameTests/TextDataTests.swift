import Foundation
import XCTest
@testable import SwiftFrameCore

class TextDataTests: XCTestCase {

    func testGoodData() throws {
        XCTAssertNoThrow(try TextData(from: TextDataContainer.goodData))
    }

    func testBadData() throws {
        XCTAssertThrowsError(try TextData(from: TextDataContainer.badData))
    }

    func testValidateData() throws {
        let textData = try TextData(from: TextDataContainer.goodData)
        XCTAssertNoThrow(try textData.validate())
    }

    func testValidateDataFailing() throws {
        let textData = try TextData(from: TextDataContainer.invalidData)
        XCTAssertThrowsError(try textData.validate())
    }

    func testConvertingOrigin() throws {
        let textData = try TextData(from: TextDataContainer.goodData)
        let size = CGSize(width: 40, height: 60)
        let convertedData = textData.convertToBottomLeftOrigin(with: size)

        XCTAssertEqual(convertedData.topLeft, Point(x: 10, y: 40))
    }

}
