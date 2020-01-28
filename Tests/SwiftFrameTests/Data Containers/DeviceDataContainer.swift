import Foundation
import SwiftFrameCore

struct DeviceDataContainer {

    static let goodData: JSONDictionary = [
        "templateFile": LocalURL(path: "testing/templatefile-debug_device1.png"),
        "outputSuffix": "iPhone X",
        "textData": [TextData.goodMockData],
        "screenshotData": [ScreenshotData.goodMockData],
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

    static let invalidData: JSONDictionary = [
        "templateFile": LocalURL(path: "testing/templatefile-debug_device1.png"),
        "outputSuffix": "iPhone X",
        "textData": [TextData.invalidMockData],
        "screenshotData": [ScreenshotData.goodMockData],
        "screenshots": LocalURL(path: "testing/screenshots/"),
        "coordinatesOriginIsTopLeft": false
    ]

    static let invertedData: JSONDictionary = [
        "templateFile": LocalURL(path: "testing/templatefile-debug_device1.png"),
        "outputSuffix": "iPhone X",
        "textData": [TextData.invertedMockData],
        "screenshotData": [ScreenshotData.invertedMockData],
        "screenshots": LocalURL(path: "testing/screenshots/"),
        "coordinatesOriginIsTopLeft": true
    ]

}

extension DeviceData {

    static var goodMockData: DeviceData {
        return try! DeviceData(from: DeviceDataContainer.goodData)
    }

    static var invertedMockData: DeviceData {
        return try! DeviceData(from: DeviceDataContainer.invertedData)
    }

    static var invalidMockData: DeviceData {
        return try! DeviceData(from: DeviceDataContainer.invalidData)
    }

}
