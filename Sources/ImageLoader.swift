import AppKit
import Foundation

final class ImageLoader {

    func loadImage(atPath path: String) throws -> NSImage {
        guard FileManager.default.fileExists(atPath: path) else {
            throw NSError(description: "Image at \(path) does not exist")
        }
        guard let image = NSImage(contentsOf: URL(fileURLWithPath: path)) else {
            throw NSError(description: "Could not load image at \(path)")
        }
        return image
    }

}
