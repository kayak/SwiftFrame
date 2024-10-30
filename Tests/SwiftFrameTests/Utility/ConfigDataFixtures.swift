import AppKit
import Foundation

@testable import SwiftFrameCore

extension ConfigData {

    static func goodData() throws -> ConfigData {
        ConfigData(
            textGroups: [],
            stringsPath: FileURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [FileURL(path: "testing/output/")],
            fontSource: .nsFont(.systemFont(ofSize: 20)),
            textColorSource: try ColorSource(hexString: "#ff00ff"),
            outputFormat: .png,
            deviceData: [.validData()]
        )
    }

    static func skippedLocaleData() throws -> ConfigData {
        ConfigData(
            textGroups: [],
            stringsPath: FileURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [FileURL(path: "testing/output/")],
            fontSource: .nsFont(.systemFont(ofSize: 20)),
            textColorSource: try ColorSource(hexString: "#ff00ff"),
            outputFormat: .png,
            deviceData: [.validData()],
            localesRegex: "^(?!en|fr$)\\w*$"
        )
    }

    static func englishOnlyData() throws -> ConfigData {
        ConfigData(
            textGroups: [],
            stringsPath: FileURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [FileURL(path: "testing/output/")],
            fontSource: .nsFont(.systemFont(ofSize: 20)),
            textColorSource: try ColorSource(hexString: "#ff00ff"),
            outputFormat: .png,
            deviceData: [.validData()],
            localesRegex: "en"
        )
    }

    static func invalidData() throws -> ConfigData {
        ConfigData(
            textGroups: [],
            stringsPath: FileURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [FileURL(path: "testing/output/")],
            fontSource: .nsFont(.systemFont(ofSize: 20)),
            textColorSource: try ColorSource(hexString: "#ff00ff"),
            outputFormat: .png,
            deviceData: [.invalidTextData]
        )
    }

}
