import Foundation
import Yams

protocol KYDecoder {

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable

}

extension JSONDecoder: KYDecoder {}

extension YAMLDecoder: KYDecoder {

    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let yamlString = String(data: data, encoding: .utf8) else {
            throw NSError(description: "Could not read specified file")
        }
        return try decode(type, from: yamlString)
    }

}

struct DecodableParser {

    private enum FileFormat: String {
        case json
        case yaml

        var decoder: KYDecoder {
            switch self {
            case .json:
                return JSONDecoder()
            case .yaml:
                
            }
        }

        init?(rawValue: String) {
            switch rawValue {
            case "json":
                self = .json
            case "yml", "yaml":
                self = .yaml
            default:
                return nil
            }
        }
    }

    static func parseData<T>(fromURL url: URL) throws -> T where T: Decodable {
        let data = try Data(contentsOf: url)
        let decoder = try determineFileFormat(forURL: url).decoder

        return try decoder.decode(T.self, from: data)
    }

    private static func determineFileFormat(forURL url: URL) throws -> FileFormat {
        if let format = FileFormat(rawValue: url.pathExtension.lowercased()) {
            return format
        } else {
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

}
