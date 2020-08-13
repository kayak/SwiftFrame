import Foundation

/// Wrapper struct to avoid some errors related to relative paths
struct FileURL: Codable {

    // MARK: - Properties

    private let url: URL

    var absoluteURL: URL {
        url.absoluteURL
    }

    var absoluteString: String {
        url.absoluteString
    }

    var path: String {
        url.path
    }

    // MARK: - Init

    init(path: String) {
        url = URL(fileURLWithPath: path)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawPath = try container.decode(String.self)
        url = URL(fileURLWithPath: rawPath)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url.path)
    }

}
