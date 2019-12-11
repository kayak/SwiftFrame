import AppKit
import Foundation

struct DeviceData: Decodable {
    let outputSuffix: String
    let screenshots: URL
    let templateFile: URL
    let screenshotData: [ScreenshotData]
    let textData: [TextData]
}

struct ScreenshotData: Decodable {
    let screenshotName: String
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
    let topLeft: CGPoint?
    let topRight: CGPoint?
    let rotationAngle: Double?
}

struct TextData: Decodable {
    let titleIdentifier: String
    let bottomLeft: CGPoint
    let topRight: CGPoint
    let maxFontSizeOverride: Int?
    let customFontPath: URL?
    let textColorOverride: NSColor?

    enum CodingKeys: String, CodingKey {
        case titleIdentifier
        case textColorOverride
        case maxFontSizeOverride
        case customFontPath
        case bottomLeft
        case topRight
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titleIdentifier = try container.decode(String.self, forKey: .titleIdentifier)
        bottomLeft = try container.decode(CGPoint.self, forKey: .bottomLeft)
        topRight = try container.decode(CGPoint.self, forKey: .topRight)
        maxFontSizeOverride = try container.decodeIfPresent(Int.self, forKey: .maxFontSizeOverride)
        customFontPath = try container.decodeIfPresent(URL.self, forKey: .customFontPath)

        if let hexString = try container.decodeIfPresent(String.self, forKey: .textColorOverride) {
            textColorOverride = try NSColor(hexString: hexString)
        } else {
            textColorOverride = nil
        }
    }
}
