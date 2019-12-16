import Foundation
import AppKit

protocol ConfigValidatable {
    func validate() throws
    func printSummary()
}

public struct ConfigFile: Decodable, ConfigValidatable {
    let deviceData: [DeviceData]
    let titlesPath: URL
    let maxFontSize: Int
    let outputPaths: [URL]
    let font: NSFont
    let textColor: NSColor

    enum CodingKeys: String, CodingKey {
        case deviceData
        case titlesPath
        case maxFontSize
        case outputPaths
        case font = "fontFile"
        case textColor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deviceData = try container.decode([DeviceData].self, forKey: .deviceData)
        titlesPath = try container.decode(URL.self, forKey: .titlesPath)
        maxFontSize = try container.decode(Int.self, forKey: .maxFontSize)
        outputPaths = try container.decode([URL].self, forKey: .outputPaths)

        let fontPath = try container.decode(URL.self, forKey: .font)
        self.font = try fontPath.registerFont()

        let colorHexString = try container.decode(String.self, forKey: .textColor)
        textColor = try NSColor(hexString: colorHexString)
    }

    func validate() throws {
        try deviceData.forEach { try $0.validate() }


    }

    func printSummary() {
        print("### Config Summary Begin")
//        for (index, text) in titleTexts.enumerated() {
//            print("Title Text #\(index + 1): \"\(text)\"")
//        }
        print("Title Color: \(textColor.hexString)")
        print("Title Font: \(font.fontName)")
        print("Title Max Font Size: \(maxFontSize)")

        print("Output paths:")
        outputPaths.forEach { print("\t" + $0.absoluteString) }
//        print("Title Padding: \(titlePadding)")
//        for (index, element) in screenshotPathsByFrame.enumerated() {
//            print("Frame #\(index + 1) Path: \(element.key.path)")
//            print("Frame #\(index + 1) Viewport: \(element.key.viewport)")
//            print("Frame #\(index + 1) Padding: \(element.key.padding)")
//            for (screenshotIndex, path) in element.value.enumerated() {
//                print("Frame #\(index + 1) Screenshot #\(screenshotIndex + 1): \(path)")
//            }
//        }
        print("### Config Summary End")
    }
}
