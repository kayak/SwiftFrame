import Foundation
@testable import SwiftFrameCore

extension DeviceData {

    static let goodData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        screenshotData: [.goodData],
        textData: [.goodData])

    static let gapData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        screenshotData: [.goodData],
        textData: [.goodData],
        gapWidth: 16)

    static let invalidData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        screenshotData: [.goodData],
        textData: [.invalidData])

    static let mismatchingDeviceSizeData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        sliceSizeOverride: DecodableSize(width: 50, height: 100),
        screenshotData: [.goodData],
        textData: [.goodData])

    static let faultyMismatchingDeviceSizeData = DeviceData(
        outputSuffixes: ["iPhone X"],
        templateImagePath: FileURL(path: "testing/templatefile-debug_device1.png"),
        screenshotsPath: FileURL(path: "testing/screenshots/"),
        sliceSizeOverride: DecodableSize(width: 50, height: 100),
        screenshotData: [.goodData],
        textData: [.goodData],
        gapWidth: 2)

}
