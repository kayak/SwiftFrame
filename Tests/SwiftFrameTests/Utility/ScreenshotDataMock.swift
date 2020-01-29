import Foundation
import SwiftFrameCore

struct ScreenshotDataMock: ConfigTestable {

    typealias T = ScreenshotData

    static var goodData: JSONDictionary {
        [
            "screenshotName": "debug_device1.png",
            "bottomLeft": Point(x: 10, y: 10),
            "bottomRight": Point(x: 40, y: 10),
            "topLeft": Point(x: 10, y: 200),
            "topRight": Point(x: 40, y: 200)
        ]
    }

    static var badData: JSONDictionary {
        [
            "screenshotName": "debug_device1.png",
            "bottomLeft": [Point(x: 10, y: 200)],
            "bottomRight": Point(x: 40, y: 200),
            "topLeft": Point(x: 10, y: 10),
            "topRight": Point(x: 40, y: 10)
        ]
    }

    static var invalidData: JSONDictionary {
        [
            "screenshotName": "debug_device1.png",
            "bottomLeft": Point(x: 10, y: 10),
            "bottomRight": Point(x: 40, y: 10),
            "topLeft": Point(x: 10, y: 200),
            "topRight": Point(x: 40, y: 200)
        ]
    }

    static var invertedData: JSONDictionary {
        [
            "screenshotName": "debug_device1.png",
            "bottomLeft": Point(x: 10, y: 200),
            "bottomRight": Point(x: 40, y: 200),
            "topLeft": Point(x: 10, y: 10),
            "topRight": Point(x: 40, y: 10)
        ]
    }

    static func makeGoodData() throws -> ScreenshotData {
        try ScreenshotData(from: goodData)
    }

    static func makeInvalidData() throws -> ScreenshotData {
        try ScreenshotData(from: invalidData)
    }

    static func makeInvertedData() throws -> ScreenshotData {
        try ScreenshotData(from: invertedData)
    }

}
