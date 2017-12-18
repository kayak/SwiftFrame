import AppKit
import Foundation

final class ImageWriter {

    func write(_ image: CGImage, toPath path: String) throws {
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: .png, properties: [:]) else {
            throw NSError(description: "Failed to convert composed image to PNG")
        }
        let url = URL(fileURLWithPath: path)
        try data.write(to: url)
    }

}
