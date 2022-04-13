import Foundation

extension NSRegularExpression {

    static func hexColorStringExpression() throws -> NSRegularExpression {
        try NSRegularExpression(pattern: "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$", options: .caseInsensitive)
    }

    static func cssColorStringExpression() throws -> NSRegularExpression {
        try NSRegularExpression(pattern: "^rgba?\\((\\d+),\\s*(\\d+),\\s*(\\d+)(?:,\\s*(\\d+(?:\\.\\d+)?))?\\)$", options: .caseInsensitive)
    }

    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: (string as NSString).length)
        return firstMatch(in: string, options: [], range: range) != nil
    }

}
