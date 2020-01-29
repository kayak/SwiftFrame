import Foundation
import SwiftFrameCore

struct DeviceDataMock: ConfigTestable {

    typealias T = DeviceData

    static var goodData: JSONDictionary {
        guard let mockTextData = try? TextDataMock.makeGoodData(), let mockScreenshotData = try? ScreenshotDataMock.makeGoodData() else {
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
            "textData": TextDataMock.badData,
            "screenshotData": [ScreenshotDataMock.badData],
            "screenshots": LocalURL(path: "testing/screenshots/")
        ]
    }

    static var invalidData: JSONDictionary {
        guard let mockTextData = try? TextDataMock.makeInvalidData(), let mockScreenshotData = try? ScreenshotDataMock.makeGoodData() else {
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
        guard let mockTextData = try? TextDataMock.makeInvertedData(), let mockScreenshotData = try? ScreenshotDataMock.makeInvertedData() else {
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
