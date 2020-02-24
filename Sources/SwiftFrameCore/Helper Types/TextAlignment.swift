import AppKit
import Foundation

enum TextAlignment: String, Codable {

    case left
    case right
    case center
    case justify
    case inherit

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
        case .inherit:
            return .natural
        }
    }

}
