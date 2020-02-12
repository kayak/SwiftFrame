import AppKit
import Foundation

enum FontSource {

    case filePath(_ path: String)
    case nsFont(_ font: NSFont)

    func makeFont() throws -> NSFont {
        try FontRegistry.shared.registerFont(from: self)
    }
}

extension FontSource: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = .filePath(try container.decode(String.self))
    }
    
}
