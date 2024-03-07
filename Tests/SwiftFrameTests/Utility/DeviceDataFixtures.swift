import Foundation
@testable import SwiftFrameCore

extension DeviceData {

    static let goodData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        numberOfSlices: 4,
        screenshotData: [.goodData],
        textData: [.goodData]
    )

    static let gapData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        numberOfSlices: 4,
        screenshotData: [.goodData],
        textData: [.goodData],
        gapWidth: 16
    )

    static let invalidData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        numberOfSlices: 4,
        screenshotData: [.goodData],
        textData: [.invalidData]
    )

    static let mismatchingDeviceSizeData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        numberOfSlices: 4,
        screenshotData: [.goodData],
        textData: [.goodData]
    )

}
