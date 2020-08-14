import AppKit
import Foundation

enum FontSource {

    case filePath(_ path: String)
    case nsFont(_ font: NSFont)

    func font() throws -> NSFont {
        try FontRegistry.shared.registerFont(from: self)
    }
}

extension FontSource: Decodable {

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = .filePath(try container.decode(String.self))
    }

}

extension FontSource: Encodable {

    func encode(to encoder: Encoder) throws {
        guard case .filePath(let path) = self else {
            throw NSError(description: "Cannot NSFont objects")
        }

        var container = encoder.singleValueContainer()
        try container.encode(path)
    }

}
