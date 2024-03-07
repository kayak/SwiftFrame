import AppKit
import Foundation
@testable import SwiftFrameCore

extension ConfigData {

    static let goodData = ConfigData(
        textGroups: [],
        stringsPath: FileURL(path: "testing/strings/"),
        maxFontSize: 200,
        outputPaths: [FileURL(path: "testing/output/")],
        fontSource: .nsFont(.systemFont(ofSize: 20)),
        textColorSource: try! ColorSource(hexString: "#ff00ff"),
        outputFormat: .png,
        deviceData: [.validData()]
    )

    static let skippedLocaleData = ConfigData(
        textGroups: [],
        stringsPath: FileURL(path: "testing/strings/"),
        maxFontSize: 200,
        outputPaths: [FileURL(path: "testing/output/")],
        fontSource: .nsFont(.systemFont(ofSize: 20)),
        textColorSource: try! ColorSource(hexString: "#ff00ff"),
        outputFormat: .png,
        deviceData: [.validData()],
        localesRegex: "^(?!en|fr$)\\w*$"
    )

    static let englishOnlyData = ConfigData(
        textGroups: [],
        stringsPath: FileURL(path: "testing/strings/"),
        maxFontSize: 200,
        outputPaths: [FileURL(path: "testing/output/")],
        fontSource: .nsFont(.systemFont(ofSize: 20)),
        textColorSource: try! ColorSource(hexString: "#ff00ff"),
        outputFormat: .png,
        deviceData: [.validData()],
        localesRegex: "en"
    )

    static let invalidData = ConfigData(
        textGroups: [],
        stringsPath: FileURL(path: "testing/strings/"),
        maxFontSize: 200,
        outputPaths: [FileURL(path: "testing/output/")],
        fontSource: .nsFont(.systemFont(ofSize: 20)),
        textColorSource: try! ColorSource(hexString: "#ff00ff"),
        outputFormat: .png,
        deviceData: [.invalidTextData]
    )

}
