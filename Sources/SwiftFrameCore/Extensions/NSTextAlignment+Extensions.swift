import AppKit

extension NSTextAlignment: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let alignmentString = try container.decode(String.self)
        switch alignmentString {
        case "left":
            self.init(rawValue: 0)!
        case "right":
            self.init(rawValue: 1)!
        case "center":
            self.init(rawValue: 2)!
        case "justify":
            self.init(rawValue: 3)!
        case "natural":
            self.init(rawValue: 4)!
        default:
            throw NSError(description: "Invalid text alignment \"\(alignmentString)\" was parsed")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(cssName)
    }

    var cssName: String {
        switch self {
        case .left:
            return "left"
        case .right:
            return "right"
        case .center:
            return "center"
        case .justified:
            return "justify"
        default:
            return "inherit"
        }
    }

}
