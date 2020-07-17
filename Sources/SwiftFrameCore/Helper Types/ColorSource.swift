import AppKit
import Foundation

struct ColorSource: Decodable {

    let hexString: String
    let color: NSColor

    init(hexString: String) throws {
        self.hexString = hexString
        self.color = try NSColor(hexString: hexString)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)
        try self.init(hexString: hexString)
    }

}
