import Foundation
import XCTest

@testable import SwiftFrameCore

class PointTests: XCTestCase {

    func testPoint_DecodesCorrectly_WhenJSONIsWellFormed() throws {
        let expectedX = 10
        let expectedY = 5

        let jsonString = "{ \"x\": \(expectedX), \"y\": \(expectedY) }"
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))

        let decodedPoint = try JSONDecoder().decode(Point.self, from: jsonData)
        XCTAssertEqual(decodedPoint, Point(x: expectedX, y: expectedY))
    }

    func testPoint_FailsToDecode_WhenJSONIsMalformed() throws {
        let jsonString = #"{ "x": 10, "yCoord": 5 }"#
        let jsonData = try XCTUnwrap(jsonString.data(using: .utf8))

        XCTAssertThrowsError(try JSONDecoder().decode(Point.self, from: jsonData))
    }

    func testPoint_ConvertsToBottomLeftOrigin() throws {
        let point = Point(x: 10, y: 5)
        let size = CGSize(width: 30, height: 30)

        let convertedPoint = point.convertingToBottomLeftOrigin(withSize: size)
        XCTAssertEqual(convertedPoint, Point(x: 10, y: 25))
    }

}
