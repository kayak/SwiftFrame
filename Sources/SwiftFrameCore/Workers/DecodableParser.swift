import Foundation
import Yams

struct DecodableParser {

    static func parseData<T>(fromURL url: URL) throws -> T where T: Decodable {
        let data = try Data(contentsOf: url)
        let decoder = try determineFileFormat(forURL: url).decoder

        return try decoder.decode(T.self, from: data)
    }

    private static func determineFileFormat(forURL url: URL) throws -> ConfigFileFormat {
        if let format = ConfigFileFormat(rawValue: url.pathExtension.lowercased()) {
            return format
        }

        let contentsOfFile = try String(contentsOf: url)
        let firstLine = contentsOfFile.components(separatedBy: .newlines).first
        if firstLine?.hasPrefix("{") ?? false {
            return .json
        } else if firstLine?.hasPrefix("---") ?? false {
            return .yaml
        } else {
            throw NSError(description: "Unknown file format")
        }
    }

}
