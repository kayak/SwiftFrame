import AppKit
import Foundation
@testable import SwiftFrameCore

extension ConfigData {

    static var goodData: Self {
        ConfigData(
            clearDirectories: true,
            outputWholeImage: true,
            textGroups: nil,
            stringsPath: FileURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [FileURL(path: "testing/output/")],
            fontSource: .nsFont(.systemFont(ofSize: 20)),
            textColorSource: try! ColorSource(hexString: "#ff00ff"),
            outputFormat: .png,
            deviceData: [.goodData])
    }

    static var invalidData: Self {
        ConfigData(
            clearDirectories: true,
            outputWholeImage: true,
            textGroups: nil,
            stringsPath: FileURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [FileURL(path: "testing/output/")],
            fontSource: .nsFont(.systemFont(ofSize: 20)),
            textColorSource: try! ColorSource(hexString: "#ff00ff"),
            outputFormat: .png,
            deviceData: [.invalidData])
    }

}
