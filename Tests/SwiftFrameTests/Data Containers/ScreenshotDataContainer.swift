import Foundation
import SwiftFrameCore

struct ScreenshotDataContainer {

    static let goodData: JSONDictionary = [
        "screenshotName": "some_Identifier",
        "bottomLeft": Point(x: 10, y: 10),
        "bottomRight": Point(x: 40, y: 10),
        "topLeft": Point(x: 10, y: 200),
        "topRight": Point(x: 40, y: 200)
    ]

    static let badData: JSONDictionary = [
        "screenshotName": "some_Identifier",
        "bottomLeft": [Point(x: 10, y: 200)],
        "bottomRight": Point(x: 40, y: 200),
        "topLeft": Point(x: 10, y: 10),
        "topRight": Point(x: 40, y: 10)
    ]

    static let invertedCoordinatesData: JSONDictionary = [
        "screenshotName": "some_Identifier",
        "bottomLeft": Point(x: 10, y: 200),
        "bottomRight": Point(x: 40, y: 200),
        "topLeft": Point(x: 10, y: 10),
        "topRight": Point(x: 40, y: 10)
    ]

}

extension ScreenshotData {

    static var goodMockData: ScreenshotData {
        return try! ScreenshotData(from: ScreenshotDataContainer.goodData)
    }

    static var invertedMockData: ScreenshotData {
        return try! ScreenshotData(from: ScreenshotDataContainer.invertedCoordinatesData)
    }

}
