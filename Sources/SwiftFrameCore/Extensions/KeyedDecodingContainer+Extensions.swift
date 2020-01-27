import Foundation

extension KeyedDecodingContainer {

    func ky_decode<T>(_ type: T.Type, forKey key: Self.Key) throws -> T where T : Decodable {
        do {
            return try decode(type, forKey: key)
        } catch let error as NSError {
            switch error.code {
            case 4865:
                throw error.withDescription("The data with key \"\(key.stringValue)\" couldn’t be read because its is missing.")
            case 4864:
                throw error.withDescription("The data with key \"\(key.stringValue)\" couldn’t be read because it isn’t in the correct format.")
            default:
                throw error
            }
        }
    }

    func ky_decodeIfPresent<T>(_ type: T.Type, forKey key: Self.Key) throws -> T? where T : Decodable {
        do {
            return try ky_decodeIfPresent(type, forKey: key)
        } catch let error as NSError {
            switch error.code {
            case 4864:
                throw error.withDescription("The data with key \"\(key.stringValue)\" couldn’t be read because it isn’t in the correct format.")
            default:
                throw error
            }
        }
    }

}
