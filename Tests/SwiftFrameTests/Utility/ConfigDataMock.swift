import AppKit
import Foundation
@testable import SwiftFrameCore

extension ConfigData {

    static var goodData: Self {
        ConfigData(
            outputWholeImage: true,
            textGroups: nil,
            stringsPath: LocalURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [LocalURL(path: "testing/output/")],
            fontSource: .nsFont(.systemFont(ofSize: 20)),
            textColorSource: try! ColorSource(hexString: "#ff00ff"),
            outputFormat: .png,
            deviceData: [DeviceData.goodData])
    }

    static var invalidData: Self {
        ConfigData(
            outputWholeImage: true,
            textGroups: nil,
            stringsPath: LocalURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [LocalURL(path: "testing/output/")],
            fontSource: .nsFont(.systemFont(ofSize: 20)),
            textColorSource: try! ColorSource(hexString: "#ff00ff"),
            outputFormat: .png,
            deviceData: [DeviceData.invalidData])
    }

}
