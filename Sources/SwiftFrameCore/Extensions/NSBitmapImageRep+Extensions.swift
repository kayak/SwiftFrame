import AppKit

extension NSBitmapImageRep {

    /// When dealing with screenshots from an iOS device for example, the size returned by the `size` property
    /// is scaled down by the UIKit scale of the device. You can use this property to get the actual pixel size
    var nativeSize: NSSize {
        NSSize(width: pixelsWide, height: pixelsHigh)
    }

    var nativeRect: NSRect {
        NSRect(origin: .zero, size: nativeSize)
    }

}

typealias FileFormat = NSBitmapImageRep.FileType

extension NSBitmapImageRep.FileType: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let format = try container.decode(String.self)
        switch format {
        case "png":
            self = .png
        case "jpeg", "jpg":
            self = .jpeg
        default:
            throw NSError(description: "Invalid output file format specified")
        }
    }

    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpeg:
            return "jpg"
        case .jpeg2000:
            return "j2p"
        case .tiff:
            return "tiff"
        case .gif:
            return "gif"
        case .bmp:
            return "bmp"
        @unknown default:
            return "png"
        }
    }

}
