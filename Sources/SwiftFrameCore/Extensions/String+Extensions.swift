import AppKit
import Foundation

extension String {

    public func formattedGreen() -> String {
        CommandLineFormatter.formatWithColorIfNeeded(self, color: .green)
    }

    func ky_containsHTMLTags() throws -> Bool {
        let regex = try NSRegularExpression(pattern: "<(.*)>.*?|<(.*)/>")
        let range = NSRange(location: 0, length: (self as NSString).length)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }

    public func ky_data(using encoding: String.Encoding = .utf8) throws -> Data {
        guard let data = self.data(using: encoding, allowLossyConversion: false) else {
            throw NSError(description: "Could not create data from string")
        }
        return data
    }

}
