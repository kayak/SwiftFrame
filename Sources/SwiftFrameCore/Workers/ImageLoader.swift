import AppKit
import Foundation

final class ImageLoader {

    // MARK: - Image Loading

    func loadImage(atPath path: String) throws -> NSImage {
        guard let image = NSImage(contentsOfFile: path) else {
            throw NSError(description: "Could not load image at \(path)")
        }
        return image
    }

    static func loadRepresentation(at url: URL) -> NSBitmapImageRep? {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return NSBitmapImageRep(data: data)
    }

}
