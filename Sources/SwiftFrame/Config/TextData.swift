import AppKit
import Foundation

struct TextData: Decodable, ConfigValidatable {
    let titleIdentifier: String
    let bottomLeft: Point
    let topRight: Point
    let maxFontSizeOverride: Int?
    let customFont: NSFont?
    let textColorOverride: NSColor?

    enum CodingKeys: String, CodingKey {
        case titleIdentifier
        case textColorOverride
        case maxFontSizeOverride
        case customFont = "customFontPath"
        case bottomLeft
        case topRight
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        titleIdentifier = try container.decode(String.self, forKey: .titleIdentifier)
        bottomLeft = try container.decode(Point.self, forKey: .bottomLeft)
        topRight = try container.decode(Point.self, forKey: .topRight)
        maxFontSizeOverride = try container.decodeIfPresent(Int.self, forKey: .maxFontSizeOverride)

        if let customFontPath = try container.decodeIfPresent(URL.self, forKey: .customFont) {
            customFont = try customFontPath.registerFont()
        } else {
            customFont = nil
        }

        if let hexString = try container.decodeIfPresent(String.self, forKey: .textColorOverride) {
            textColorOverride = try NSColor(hexString: hexString)
        } else {
            textColorOverride = nil
        }
    }

    func validate() throws {

    }

    func printSummary() {

    }
}
