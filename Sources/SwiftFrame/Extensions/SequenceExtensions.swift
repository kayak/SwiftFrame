import Foundation

extension Dictionary {

    subscript(safe key: Key?) -> Value? {
        guard let key = key else {
            return nil
        }
        return self[key]
    }

}
