import AppKit
import Foundation

final class ImageLoader {

    // MARK: - Image Loading

    func loadImage(atURL url: URL) throws -> NSImage {
        guard let image = NSImage(contentsOf: url) else {
            throw NSError(description: "Could not load image at \(url.absoluteString)")
        }
        return image
    }

    func loadImage(atPath path: String) throws -> NSImage {
        guard let image = NSImage(contentsOfFile: path) else {
            throw NSError(description: "Could not load image at \(path)")
        }
        return image
    }

}
