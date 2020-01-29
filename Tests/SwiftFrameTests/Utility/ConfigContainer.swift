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

struct ConfigContainer: ConfigTestable {

    typealias T = ConfigData

    static var goodData: JSONDictionary {
        guard let mockDeviceData = try? DeviceDataContainer.makeGoodData() else {
            preconditionFailure("Constructing device data shouldnt fail here")
        }

        return [
            "deviceData": [mockDeviceData],
            "titlesPath": LocalURL(path: "testing/strings/"),
            "maxFontSize": CGFloat(200.00),
            "outputPaths": [LocalURL(path: "testing/output/")],
            "fontFile": NSFont.systemFont(ofSize: 20),
            "textColor": NSColor.red
        ]
    }

    static var badData: JSONDictionary {
        [
            "deviceData": [DeviceDataContainer.badData],
            "titlesPath": LocalURL(path: "testing/strings/"),
            "maxFontSize": 200,
            "outputPaths": [LocalURL(path: "testing/output/")],
            "fontFile": NSFont.systemFont(ofSize: 20),
            "textColor": "#ff0000"
        ]
    }

    static var invalidData: JSONDictionary {
        guard let mockDeviceData = try? DeviceDataContainer.makeInvalidData() else {
            preconditionFailure("Constructing device data shouldnt fail here")
        }

        return [
            "deviceData": [mockDeviceData],
            "titlesPath": LocalURL(path: "testing/strings/"),
            "maxFontSize": CGFloat(200.00),
            "outputPaths": [LocalURL(path: "testing/output/")],
            "fontFile": NSFont.systemFont(ofSize: 20),
            "textColor": NSColor.red
        ]
    }

    static var invertedData: JSONDictionary {
        guard let mockDeviceData = try? DeviceDataContainer.makeInvertedData() else {
            preconditionFailure("Constructing device data shouldnt fail here")
        }

        return [
            "deviceData": [mockDeviceData],
            "titlesPath": LocalURL(path: "testing/strings/"),
            "maxFontSize": CGFloat(200.00),
            "outputPaths": [LocalURL(path: "testing/output/")],
            "fontFile": NSFont.systemFont(ofSize: 20),
            "textColor": NSColor.red
        ]
    }

    static func makeGoodData() throws -> ConfigData {
        try ConfigData(from: goodData)
    }

    static func makeInvalidData() throws -> ConfigData {
        try ConfigData(from: invalidData)
    }

    static func makeInvertedData() throws -> ConfigData {
        try ConfigData(from: invertedData)
    }

}
