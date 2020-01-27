import Foundation
import XCTest
@testable import SwiftFrameCore

class TextDataTests: XCTestCase {

    let goodData: [String : Any] = [
        "titleIdentifier": "someID",
        "textAlignment": "center",
        "topLeft": [
            "x": 10,
            "y": 20
        ],
        "bottomRight": [
            "x": 15,
            "y": 5
        ]
    ]

    let badData: [String : Any] = [
        "titleIdentifier": "someID",
        "textAlignment": 1,
        "topLeft": [
            "x": 10,
            "y": 5
        ],
        "bottomRight": [
            "x": 15,
            "y": 20
        ]
    ]

    let invalidData: [String : Any] = [
        "titleIdentifier": "someID",
        "textAlignment": "center",
        "topLeft": [
            "x": 10,
            "y": 5
        ],
        "bottomRight": [
            "x": 8,
            "y": 20
        ]
    ]

    func testGoodData() throws {
        let json = try makeJSON(from: goodData)
        XCTAssertNoThrow(try JSONDecoder().decode(TextData.self, from: json))
    }

    func testBadData() throws {
        let json = try makeJSON(from: badData)
        XCTAssertThrowsError(try JSONDecoder().decode(TextData.self, from: json))
    }

    func testValidateData() throws {
        let json = try makeJSON(from: goodData)
        let textData = try JSONDecoder().decode(TextData.self, from: json)
        XCTAssertNoThrow(try textData.validate())
    }

    func testValidateDataFailing() throws {
        let json = try makeJSON(from: invalidData)
        let textData = try JSONDecoder().decode(TextData.self, from: json)
        XCTAssertThrowsError(try textData.validate())
    }

    func testConvertingOrigin() throws {
        let json = try makeJSON(from: goodData)
        let textData = try JSONDecoder().decode(TextData.self, from: json)
        let size = CGSize(width: 40, height: 60)
        let convertedData = textData.convertToBottomLeftOrigin(with: size)

        XCTAssertEqual(convertedData.topLeft, Point(x: 10, y: 40))
    }

}

func makeJSON(from dict: [String: Any]) throws -> Data {
    try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
}
