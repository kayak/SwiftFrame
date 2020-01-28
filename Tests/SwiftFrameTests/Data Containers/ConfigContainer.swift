import AppKit
import Foundation
import SwiftFrameCore

struct ConfigContainer {

    static let goodData: JSONDictionary = [
        "deviceData": [DeviceData.goodMockData, .invertedMockData],
        "titlesPath": LocalURL(path: "testing/strings/"),
        "maxFontSize": CGFloat(200.00),
        "outputPaths": [LocalURL(path: "testing/output/")],
        "fontFile": NSFont.systemFont(ofSize: 20),
        "textColor": NSColor.red
    ]

    static let badData: JSONDictionary = [
        "deviceData": [DeviceData.goodMockData, .invertedMockData],
        "titlesPath": LocalURL(path: "testing/strings/"),
        "maxFontSize": 200,
        "outputPaths": [LocalURL(path: "testing/output/")],
        "fontFile": NSFont.systemFont(ofSize: 20),
        "textColor": "#ff0000"
    ]

    static let invalidData: JSONDictionary = [
        "deviceData": [DeviceData.invalidMockData],
        "titlesPath": LocalURL(path: "testing/strings/"),
        "maxFontSize": CGFloat(200.00),
        "outputPaths": [LocalURL(path: "testing/output/")],
        "fontFile": NSFont.systemFont(ofSize: 20),
        "textColor": NSColor.red
    ]

}
