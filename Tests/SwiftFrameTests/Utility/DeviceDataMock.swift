import Foundation
import SwiftFrameCore

extension DeviceData {

    static var goodData: Self {
        DeviceData(
            outputSuffix: "iPhone X",
            templateImagePath: LocalURL(path: "testing/templatefile-debug_device1.png"),
            screenshotsPath: LocalURL(path: "testing/screenshots/"),
            coordinateOriginIsTopLeft: false,
            screenshotData: [ScreenshotData.goodData],
            textData: [TextData.goodData])
    }

    static var invalidData: Self {
        DeviceData(
            outputSuffix: "iPhone X",
            templateImagePath: LocalURL(path: "testing/templatefile-debug_device1.png"),
            screenshotsPath: LocalURL(path: "testing/screenshots/"),
            coordinateOriginIsTopLeft: false,
            screenshotData: [ScreenshotData.goodData],
            textData: [TextData.invalidData])
    }

    static var invertedData: Self {
        DeviceData(
            outputSuffix: "iPhone X",
            templateImagePath: LocalURL(path: "testing/templatefile-debug_device1.png"),
            screenshotsPath: LocalURL(path: "testing/screenshots/"),
            coordinateOriginIsTopLeft: false,
            screenshotData: [ScreenshotData.invertedData],
            textData: [TextData.invertedData])
    }

}
