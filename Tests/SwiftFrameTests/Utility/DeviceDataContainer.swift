import Foundation
import SwiftFrameCore

struct DeviceDataContainer: ConfigTestable {

    typealias T = DeviceData

    static var goodData: JSONDictionary {
        guard let mockTextData = try? TextDataContainer.makeGoodData(), let mockScreenshotData = try? ScreenshotDataContainer.makeGoodData() else {
            preconditionFailure("Constructing text and screenshot data shouldnt fail")
        }

        return [
            "templateFile": LocalURL(path: "testing/templatefile-debug_device1.png"),
            "outputSuffix": "iPhone X",
            "textData": [mockTextData],
            "screenshotData": [mockScreenshotData],
            "screenshots": LocalURL(path: "testing/screenshots/"),
            "coordinatesOriginIsTopLeft": false
        ]
    }

    static var badData: JSONDictionary {
        [
            "templateFile": LocalURL(path: "testing/templatefile-debug_device1.png"),
            "outputSuffix": "iPhone X",
            "textData": TextDataContainer.badData,
            "screenshotData": [ScreenshotDataContainer.badData],
            "screenshots": LocalURL(path: "testing/screenshots/")
        ]
    }

    static var invalidData: JSONDictionary {
        guard let mockTextData = try? TextDataContainer.makeInvalidData(), let mockScreenshotData = try? ScreenshotDataContainer.makeGoodData() else {
            preconditionFailure("Constructing text and screenshot data shouldnt fail")
        }

        return [
            "templateFile": LocalURL(path: "testing/templatefile-debug_device1.png"),
            "outputSuffix": "iPhone X",
            "textData": [mockTextData],
            "screenshotData": [mockScreenshotData],
            "screenshots": LocalURL(path: "testing/screenshots/"),
            "coordinatesOriginIsTopLeft": false
        ]
    }

    static var invertedData: JSONDictionary {
        guard let mockTextData = try? TextDataContainer.makeInvertedData(), let mockScreenshotData = try? ScreenshotDataContainer.makeInvertedData() else {
            preconditionFailure("Constructing text and screenshot data shouldnt fail")
        }

        return [
            "templateFile": LocalURL(path: "testing/templatefile-debug_device1.png"),
            "outputSuffix": "iPhone X",
            "textData": [mockTextData],
            "screenshotData": [mockScreenshotData],
            "screenshots": LocalURL(path: "testing/screenshots/"),
            "coordinatesOriginIsTopLeft": true
        ]
    }

    static func makeGoodData() throws -> DeviceData {
        try DeviceData(from: goodData)
    }

    static func makeInvalidData() throws -> DeviceData {
        try DeviceData(from: invalidData)
    }

    static func makeInvertedData() throws -> DeviceData {
        try DeviceData(from: invertedData)
    }

}
