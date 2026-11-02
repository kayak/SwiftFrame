import AppKit
import Foundation

struct TextAlignment: Codable, Equatable {

    // MARK: - Nested Types

    enum Horizontal: String, Codable {

        case left
        case right
        case center
        case justify
        case natural

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
            case .natural:
                return .natural
            }
        }

    }

    enum Vertical: String, Codable {
        case top, center, bottom
    }

    // MARK: - Properties

    let horizontal: Horizontal
    let vertical: Vertical

}
