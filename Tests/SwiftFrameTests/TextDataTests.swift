import Foundation
import XCTest
@testable import SwiftFrameCore

class TextDataTests: XCTestCase {

    let goodData: [String : Any] = [
        "titleIdentifier": "someID",
        "textAlignment": NSTextAlignment.center,
        "topLeft": Point(x: 10, y: 20),
        "bottomRight": Point(x: 15, y: 5)
    ]

    let badData: [String : Any] = [
        "titleIdentifier": "someID",
        "textAlignment": 1,
        "topLeft": Point(x: 15, y: 5),
        "bottomRight": Point(x: 15, y: 20)
    ]

    let invalidData: [String : Any] = [
        "titleIdentifier": "someID",
        "textAlignment": NSTextAlignment.center,
        "topLeft": Point(x: 10, y: 5),
        "bottomRight": Point(x: 8, y: 20)
    ]

    func testGoodData() throws {
        XCTAssertNoThrow(try TextData(from: goodData))
    }

    func testBadData() throws {
        XCTAssertThrowsError(try TextData(from: badData))
    }

    func testValidateData() throws {
        let textData = try TextData(from: goodData)
        XCTAssertNoThrow(try textData.validate())
    }

    func testValidateDataFailing() throws {
        let textData = try TextData(from: invalidData)
        XCTAssertThrowsError(try textData.validate())
    }

    func testConvertingOrigin() throws {
        let textData = try TextData(from: goodData)
        let size = CGSize(width: 40, height: 60)
        let convertedData = textData.convertToBottomLeftOrigin(with: size)

        XCTAssertEqual(convertedData.topLeft, Point(x: 10, y: 40))
    }

}
