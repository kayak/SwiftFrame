import Foundation

/// Wrapper struct to avoid some errors related to relative paths
public struct LocalURL: Codable {

    // MARK: - Properties

    let rawPath: String
    private let url: URL

    public var absoluteURL: URL {
        url.absoluteURL
    }

    public var absoluteString: String {
        url.absoluteString
    }

    // MARK: - Init

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawPath = try container.decode(String.self)
        url = URL(fileURLWithPath: rawPath)
    }

}
