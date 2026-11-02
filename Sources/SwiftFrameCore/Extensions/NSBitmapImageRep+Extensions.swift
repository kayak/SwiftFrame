import AppKit

extension NSBitmapImageRep {

    static func ky_loadFromURL(_ url: URL?) -> NSBitmapImageRep? {
        guard let url else {
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
