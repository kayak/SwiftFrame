import AppKit
import Foundation

struct TextAlignment: Codable, Equatable {

    enum Horizontal: String, Codable {

        case left
        case right
        case center
        case justify

        var nsAlignment: NSTextAlignment {
            switch self {
            case .left:
                return .left
            case .right:
                return .right
            case .center:
                return .center
            case .justify:
                return .justified
            }
        }

    }

    enum Vertical: String, Codable {
        case top, center, bottom
    }

    let horizontal: Horizontal
    let vertical: Vertical

    init(horizontal: Horizontal, vertical: Vertical) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

}
