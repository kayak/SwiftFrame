import AppKit

extension NSBitmapImageRep {

    /// When dealing with screenshots from an iOS device for example, the size returned by the `size` property
    /// is scaled down by the UIKit scale of the device. You can use this property to get the actual pixel size
    var ky_nativeSize: NSSize {
        NSSize(width: pixelsWide, height: pixelsHigh)
    }

    var ky_nativeRect: NSRect {
        NSRect(origin: .zero, size: ky_nativeSize)
    }

    static func ky_loadFromURL(_ url: URL?) -> NSBitmapImageRep? {
        guard let url = url else {
            return nil
        }
        return ImageLoader.loadRepresentation(at: url)
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
        default:
            return "png"
        }
    }

}
