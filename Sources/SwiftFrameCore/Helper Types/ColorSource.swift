import AppKit
import Foundation

struct ColorSource: Decodable {

    let sourceString: String
    let color: NSColor

    init(sourceString: String) throws {
        self.sourceString = sourceString

        if isValidHexString(sourceString) {
            self.color = try NSColor(hexString: sourceString)
        } else if isValidRGBAString(sourceString) {
            self.color = try NSColor(rgbaString: sourceString)
        } else {
            throw NSError(
                description: "Color source string \"\(sourceString)\" is not a valid color representation",
                expectation: "Colors should have the format #23F67A, rgb(1, 0.5, 0.3) or rgba(0.1, 0.67, 0.233, 1.0)",
                actualValue: sourceString
            )
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let sourceString = try container.decode(String.self)
        try self.init(sourceString: sourceString)
    }

}
