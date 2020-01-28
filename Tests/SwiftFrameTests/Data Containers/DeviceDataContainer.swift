import Foundation
import SwiftFrameCore

struct DeviceDataContainer {

    static let goodData: JSONDictionary = [
        "templateFile": LocalURL(path: "testing/templatefile-debug_device1.png"),
        "outputSuffix": "iPhone X",
        "textData": [TextData.mockData],
        "screenshotData": [ScreenshotData.goodMockData, ScreenshotData.invertedMockData],
        "screenshots": LocalURL(path: "testing/screenshots/"),
        "coordinatesOriginIsTopLeft": false
    ]

    static let badData: JSONDictionary = [
        "templateFile": LocalURL(path: "testing/templatefile-debug_device1.png"),
        "outputSuffix": "iPhone X",
        "textData": TextDataContainer.badData,
        "screenshotData": [ScreenshotDataContainer.badData],
        "screenshots": LocalURL(path: "testing/screenshots/")
    ]

}
