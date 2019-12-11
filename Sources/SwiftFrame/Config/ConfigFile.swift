import Foundation
import AppKit

public struct ConfigFile: Decodable {
    let deviceData: [String: DeviceData]
    let titlesPath: URL
    let maxFontSize: Int
    let outputPaths: [URL]
    let fontFile: URL
    let textColor: NSColor

    enum CodingKeys: String, CodingKey {
        case deviceData
        case titlesPath
        case maxFontSize
        case outputPaths
        case fontFile
        case textColor
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        deviceData = try container.decode([String: DeviceData].self, forKey: .deviceData)
        titlesPath = try container.decode(URL.self, forKey: .titlesPath)
        maxFontSize = try container.decode(Int.self, forKey: .maxFontSize)
        outputPaths = try container.decode([URL].self, forKey: .outputPaths)
        fontFile = try container.decode(URL.self, forKey: .fontFile)

        let colorHexString = try container.decode(String.self, forKey: .textColor)
        textColor = try NSColor(hexString: colorHexString)
    }
}
