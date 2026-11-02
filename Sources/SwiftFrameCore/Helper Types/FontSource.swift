import AppKit
import Foundation

enum FontSource: Sendable {

    case filePath(_ path: String)
    case systemFont(ofSize: CGFloat)

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
