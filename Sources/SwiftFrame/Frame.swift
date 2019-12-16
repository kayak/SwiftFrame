import AppKit
import Foundation

class Frame: Equatable, Hashable {

    let path: String
    let padding: Int
    let hasNotch: Bool
    let nameRegex: NSRegularExpression
    let viewport: NSRect
    let viewportMask: NSImage?
    let image: NSImage

    // MARK: - Object Lifecycle

    init(path: String, padding: Int, hasNotch: Bool, namePattern: String, viewport: NSRect? = nil, viewportComputer: ViewportComputerProtocol? = nil) throws {
        self.path = path
        self.padding = padding
        self.hasNotch = hasNotch
        self.nameRegex = try NSRegularExpression(pattern: namePattern, options: [])
        let image = try ImageLoader().loadImage(atPath: path)
        let computer = viewportComputer ?? ViewportComputer()
        guard let viewport = viewport ?? computer.computeViewportRect(from: image, hasNotch: hasNotch) else {
            throw NSError(description: "Failed to auto-compute viewport for device frame at \(path)")
        }
        self.viewport = viewport
        self.viewportMask = try computer.computeViewportMask(from: image, with: viewport)
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

    func hash(into hasher: inout Hasher) {
        hasher.combine(path.hashValue)
    }

}
