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
            textData: [.goodData],
            gapWidth: gapWidth
        )
    }

    static let invalidTextData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        numberOfSlices: 4,
        screenshotData: [.goodData],
        textData: [.invalidData]
    )

    static let invalidNumberOfSlices = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        numberOfSlices: 0,
        screenshotData: [.goodData],
        textData: [.goodData]
    )

    static let invalidGapWidth = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        numberOfSlices: 5,
        screenshotData: [.goodData],
        textData: [.goodData],
        gapWidth: -10
    )

}
