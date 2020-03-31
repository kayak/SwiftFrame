import Foundation
@testable import SwiftFrameCore

extension DeviceData {

    static var goodData: Self {
        DeviceData(
            outputSuffix: "iPhone X",
            templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
            screenshotsPath: FileURL(path: "testing/screenshots/"),
            screenshotData: [.goodData],
            textData: [.goodData])
    }

    static var gapData: Self {
        DeviceData(
            outputSuffix: "iPhone X",
            templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
            screenshotsPath: FileURL(path: "testing/screenshots/"),
            screenshotData: [.goodData],
            textData: [.goodData],
            gapWidth: 16)
    }

    static var invalidData: Self {
        DeviceData(
            outputSuffix: "iPhone X",
            templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
            screenshotsPath: FileURL(path: "testing/screenshots/"),
            screenshotData: [.goodData],
            textData: [.invalidData])
    }

}
