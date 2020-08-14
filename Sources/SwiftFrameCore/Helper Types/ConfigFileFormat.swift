import Foundation
import Yams

public enum ConfigFileFormat: String {
    case json
    case yaml

    public init?(rawValue: String) {
        switch rawValue {
        case "json", "config":
            self = .json
        case "yml", "yaml":
            self = .yaml
        default:
            return nil
        }
    }
}

extension ConfigFileFormat {

    var decoder: KYDecoder {
        switch self {
        case .json:
            return JSONDecoder()
        case .yaml:
            return YAMLDecoder()
        }
    }

    var encoder: KYEncoder {
        switch self {
        case .json:
            let encoder = JSONEncoder()
            if #available(OSX 10.15, *) {
                encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
            } else {
                encoder.outputFormatting = .prettyPrinted
            }

            return encoder
        case .yaml:
            return YAMLEncoder()
        }
    }

}
