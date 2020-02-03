import AppKit
import Foundation
import SwiftFrameCore

protocol ConfigTestable {
    associatedtype T

    static var goodData: JSONDictionary { get }
    static var badData: JSONDictionary { get }
    static var invalidData: JSONDictionary { get }
    static var invertedData: JSONDictionary { get }

    static func makeGoodData() throws -> T
    static func makeInvalidData() throws -> T
    static func makeInvertedData() throws -> T
}

extension ConfigData {

    static var goodData: Self {
        ConfigData(
            textGroups: nil,
            titlesPath: LocalURL(path: "testing/strings/"),
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
            titlesPath: LocalURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [LocalURL(path: "testing/output/")],
            fontPath: "",
            textColorString: "#ff00ff",
            deviceData: [DeviceData.invalidData],
            font: .systemFont(ofSize: 20),
            textColor: .red)
    }

    static var invertedData: Self {
        ConfigData(
            textGroups: nil,
            titlesPath: LocalURL(path: "testing/strings/"),
            maxFontSize: 200,
            outputPaths: [LocalURL(path: "testing/output/")],
            fontPath: "",
            textColorString: "#ff00ff",
            deviceData: [DeviceData.invertedData],
            font: .systemFont(ofSize: 20),
            textColor: .red)
    }

}
