import AppKit
import Foundation

class Frame: Equatable, Hashable {

    let path: String
    let padding: Int
    let nameRegex: NSRegularExpression
    let viewport: NSRect
    let image: NSImage

    // MARK: - Object Lifecycle

    init(path: String, padding: Int, namePattern: String, viewport: NSRect? = nil, viewportComputer: ViewportComputerProtocol? = nil) throws {
        self.path = path
        self.padding = padding
        self.nameRegex = try NSRegularExpression(pattern: namePattern, options: [])
        let image = try ImageLoader().loadImage(atPath: path)
        guard let viewport = viewport ?? (viewportComputer ?? ViewportComputer()).compute(from: image) else {
            throw NSError(description: "Failed to auto-compute viewport for device frame at \(path)")
        }
        self.viewport = viewport
        self.image = image
    }

    // MARK: - File Name Matching

    func matches(path: String) -> Bool {
        let filename = (path as NSString).lastPathComponent as String
        return nameRegex.firstMatch(in: filename, options: [], range: NSRange(location: 0, length: filename.count)) != nil
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
