import Foundation

public struct LocalURL: Codable {
    let rawPath: String
    private let url: URL

    public var absoluteURL: URL {
        url.absoluteURL
    }

    public var absoluteString: String {
        url.absoluteString
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawPath = try container.decode(String.self)
        url = URL(fileURLWithPath: rawPath)
    }
}
