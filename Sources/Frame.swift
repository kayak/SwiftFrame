import Foundation

struct Frame: Equatable, Hashable {

    let path: String
    let viewport: NSRect
    let padding: Int
    let nameRegex: NSRegularExpression

    // MARK: - Object Lifecycle

    init(path: String, viewport: NSRect, padding: Int, namePattern: String) throws {
        self.path = path
        self.viewport = viewport
        self.padding = padding
        self.nameRegex = try NSRegularExpression(pattern: namePattern, options: [])
    }

    // MARK: - File Name Matching

    func matches(path: String) -> Bool {
        let filename = (path as NSString).lastPathComponent as String
        return nameRegex.firstMatch(in: filename, options: [], range: NSRange(location: 0, length: filename.characters.count)) != nil
    }

    // MARK: - Equatable

    static func ==(lhs: Frame, rhs: Frame) -> Bool {
        return lhs.path == rhs.path && lhs.viewport == rhs.viewport && lhs.padding == rhs.padding && rhs.nameRegex == lhs.nameRegex
    }

    // MARK: - Hashable

    var hashValue: Int {
        return path.hashValue
    }

}
