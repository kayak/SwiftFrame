import AppKit
import Foundation
import SwiftFrameCore

struct TextDataContainer: ConfigTestable {

    typealias T = TextData

    static var goodData: JSONDictionary {
        [
            "titleIdentifier": "someID",
            "textAlignment": NSTextAlignment.center,
            "topLeft": Point(x: 10, y: 20),
            "bottomRight": Point(x: 15, y: 5)
        ]
    }

    static var badData: JSONDictionary {
        [
            "titleIdentifier": "someID",
            "textAlignment": 1,
            "topLeft": Point(x: 15, y: 5),
            "bottomRight": Point(x: 15, y: 20)
        ]
    }

    static var invalidData: JSONDictionary {
        [
            "titleIdentifier": "someID",
            "textAlignment": NSTextAlignment.center,
            "topLeft": Point(x: 10, y: 5),
            "bottomRight": Point(x: 8, y: 20)
        ]
    }

    static var invertedData: JSONDictionary {
        [
            "titleIdentifier": "someID",
            "textAlignment": NSTextAlignment.center,
            "topLeft": Point(x: 10, y: 5),
            "bottomRight": Point(x: 15, y: 20)
        ]
    }

    static func makeGoodData() throws -> TextData {
        try TextData(from: goodData)
    }

    static func makeInvalidData() throws -> TextData {
        try TextData(from: invalidData)
    }

    static func makeInvertedData() throws -> TextData {
        try TextData(from: invertedData)
    }

}
