import Foundation
import Yams

protocol KYDecoder {

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T

}

protocol KYEncoder {

    func encode<T: Encodable>(_ object: T) throws -> Data

}

extension JSONDecoder: KYDecoder {}
extension JSONEncoder: KYEncoder {}

extension YAMLDecoder: KYDecoder {

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        guard let yamlString = String(data: data, encoding: .utf8) else {
            throw NSError(description: "Could not read specified file")
        }
        return try decode(type, from: yamlString)
    }

}

extension YAMLEncoder: KYEncoder {

    func encode<T>(_ object: T) throws -> Data where T : Encodable {
        let yamlString: String = try encode(object)
        return try yamlString.ky_data(using: .utf8)
    }

}
