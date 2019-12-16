import AppKit
import Foundation

final class ImageLoader {

    func loadImage(atURL url: URL) throws -> NSImage {
        guard let image = NSImage(contentsOf: url) else {
            throw NSError(description: "Could not load image at \(url.absoluteString)")
        }
        return image
    }

    func loadImage(atPath path: String) throws -> NSImage {
        guard FileManager.default.fileExists(atPath: path) else {
            throw NSError(description: "Image at \(path) does not exist")
        }
        guard let image = NSImage(contentsOfFile: path) else {
            throw NSError(description: "Could not load image at \(path)")
        }
        return image
    }

    func loadImage(atPath path: String, forSize size: CGSize, allowDownsampling: Bool) throws -> NSImage {
        guard FileManager.default.fileExists(atPath: path) else {
            throw NSError(description: "Image at \(path) does not exist")
        }
        guard let representations = NSBitmapImageRep.imageReps(withContentsOfFile: path), !representations.isEmpty else {
            throw NSError(description: "Could not load image at \(path)")
        }
        guard let representation = representation(from: representations, forSize: size, allowDownSampling: allowDownsampling) else {
            throw NSError(description: "Could not find representation that fits into size \(size) for image at \(path). "
                + "Available sizes: \(representations.map({ CGSize(width: $0.pixelsWide, height: $0.pixelsHigh) }))")
        }
        let image = NSImage(size: CGSize(width: representation.pixelsWide, height: representation.pixelsHigh))
        image.addRepresentation(representation)
        return image
    }

    func representation(from representations: [NSImageRep], forSize size: CGSize, allowDownSampling: Bool) -> NSImageRep? {
        guard allowDownSampling else {
            return representations.first(where: { $0.pixelsWide == Int(size.width) && $0.pixelsHigh == Int(size.height) })
        }
        return representations.first(where: { representation in
            let scale = size.width / CGFloat(representation.pixelsWide)
            let representationSize = CGSize(width: representation.pixelsWide, height: representation.pixelsHigh)
            return scale <= 1 && representationSize.applying(CGAffineTransform(scaleX: scale, y: scale)).equalTo(size)
        })
    }

}
