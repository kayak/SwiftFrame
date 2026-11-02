import Foundation

@testable import SwiftFrameCore

extension DeviceData {

    static func validData(gapWidth: Int = 0) -> DeviceData {
        DeviceData(
            outputSuffixes: ["iPhone X"],
            templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
            screenshotsPath: FileURL(path: "testing/screenshots/"),
            numberOfSlices: 4,
            screenshotData: [.goodData],
            textData: [.validData],
            gapWidth: gapWidth
        )
    }

    static let invalidTextData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        numberOfSlices: 4,
        screenshotData: [.goodData],
        textData: [.invalidTextBounds]
    )

    static let invalidNumberOfSlices = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        numberOfSlices: 0,
        screenshotData: [.goodData],
        textData: [.validData]
    )

    static let invalidGapWidth = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        numberOfSlices: 5,
        screenshotData: [.goodData],
        textData: [.validData],
        gapWidth: -10
    )

}
