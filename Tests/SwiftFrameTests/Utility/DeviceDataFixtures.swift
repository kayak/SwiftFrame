import Foundation
@testable import SwiftFrameCore

extension DeviceData {

    static let goodData = DeviceData(
        outputSuffix: "iPhone X",
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        screenshotData: [.goodData],
        textData: [.goodData])

    static let gapData = DeviceData(
        outputSuffix: "iPhone X",
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        screenshotData: [.goodData],
        textData: [.goodData],
        gapWidth: 16)

    static let invalidData = DeviceData(
        outputSuffix: "iPhone X",
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        screenshotData: [.goodData],
        textData: [.invalidData])

}
