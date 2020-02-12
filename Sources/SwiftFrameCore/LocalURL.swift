import Foundation

/// Wrapper struct to avoid some errors related to relative paths
struct LocalURL: Decodable {

    // MARK: - Properties

    let rawPath: String
    private let url: URL

    var absoluteURL: URL {
        url.absoluteURL
    }

    var absoluteString: String {
        url.absoluteString
    }

    // MARK: - Init

    init(path: String) {
        rawPath = path
        url = URL(fileURLWithPath: rawPath)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawPath = try container.decode(String.self)
        url = URL(fileURLWithPath: rawPath)
    }

}
