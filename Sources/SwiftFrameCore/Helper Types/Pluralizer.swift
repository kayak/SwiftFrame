import Foundation

enum Pluralizer {

    static func pluralize(_ value: Int, singular: String, plural: String, zero: String? = nil) -> String {
        let absoluteValue = abs(value)
        return switch absoluteValue {
        case 0:
            "\(value) \(zero ?? plural)"
        case 1:
            "\(value) \(singular)"
        default:
            "\(value) \(plural)"
        }
    }

}
