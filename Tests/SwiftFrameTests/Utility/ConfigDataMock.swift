import AppKit
import Foundation
import SwiftFrameCore

extension ConfigData {

    static var goodData: Self {
        ConfigData(
            textGroups: nil,
            stringsPath: LocalURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [LocalURL(path: "testing/output/")],
            fontPath: "",
            textColorString: "#ff00ff",
            deviceData: [DeviceData.goodData],
            font: .systemFont(ofSize: 20),
            textColor: .red)
    }

    static var invalidData: Self {
        ConfigData(
            textGroups: nil,
            stringsPath: LocalURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [LocalURL(path: "testing/output/")],
            fontPath: "",
            textColorString: "#ff00ff",
            deviceData: [DeviceData.invalidData],
            font: .systemFont(ofSize: 20),
            textColor: .red)
    }

}
