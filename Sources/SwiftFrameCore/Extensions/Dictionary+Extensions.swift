import Foundation

public extension Dictionary {

    subscript(safe key: Key?) -> Value? {
        guard let key = key else {
            return nil
        }
        return self[key]
    }

}

extension Dictionary where Key == String {

    func ky_decode<T>(with key: CodingKey) throws -> T {
        guard let value = self[key.stringValue] else {
            throw NSError(description: "The data with key \"\(key.stringValue)\" couldn’t be read because its is missing.")
        }
        guard let castedValue = value as? T else {
            throw NSError(description: "The data with key \"\(key.stringValue)\" couldn’t be read because it isn’t in the correct format.")
        }
        return castedValue
    }

    func ky_decodeIfPresent<T>(with key: CodingKey) throws -> T? {
        guard let value = self[key.stringValue] else {
            return nil
        }
        guard let castedValue = value as? T else {
            throw NSError(description: "The data with key \"\(key.stringValue)\" couldn’t be read because it isn’t in the correct format.")
        }
        return castedValue
    }

}
