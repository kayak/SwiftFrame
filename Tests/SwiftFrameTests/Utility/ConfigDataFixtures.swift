import AppKit
import Foundation
@testable import SwiftFrameCore

extension ConfigData {

    static var goodData: Self {
        ConfigData(
            textGroups: [],
            stringsPath: FileURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [FileURL(path: "testing/output/")],
            fontSource: .nsFont(.systemFont(ofSize: 20)),
            textColorSource: try! ColorSource(hexString: "#ff00ff"),
            outputFormat: .png,
            clearDirectories: true,
            outputWholeImage: true,
            deviceData: [.goodData])
    }

    static var invalidData: Self {
        ConfigData(
            textGroups: [],
            stringsPath: FileURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [FileURL(path: "testing/output/")],
            fontSource: .nsFont(.systemFont(ofSize: 20)),
            textColorSource: try! ColorSource(hexString: "#ff00ff"),
            outputFormat: .png,
            clearDirectories: true,
            outputWholeImage: true,
            deviceData: [.invalidData])
    }

}
