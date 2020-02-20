import Foundation
@testable import SwiftFrameCore

extension DeviceData {

    static var goodData: Self {
        DeviceData(
            outputSuffix: "iPhone X",
            templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
            screenshotsPath: FileURL(path: "testing/screenshots/"),
            screenshotData: [ScreenshotData.goodData],
            textData: [TextData.goodData])
    }

    static var invalidData: Self {
        DeviceData(
            outputSuffix: "iPhone X",
            templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
            screenshotsPath: FileURL(path: "testing/screenshots/"),
            screenshotData: [ScreenshotData.goodData],
            textData: [TextData.invalidData])
    }

}
