import Foundation

struct LocalURL: Codable {
    let rawPath: String
    private let url: URL

    var absoluteURL: URL {
        url.absoluteURL
    }

    var absoluteString: String {
        url.absoluteString
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawPath = try container.decode(String.self)
        url = URL(fileURLWithPath: rawPath)
    }
}
