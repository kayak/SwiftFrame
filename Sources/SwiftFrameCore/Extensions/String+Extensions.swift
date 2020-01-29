import AppKit
import Foundation

extension String {

    public func formattedGreen() -> String {
        "\u{001B}[0;32m" + self + "\u{001B}[0;39m"
    }

    func formattedRed() -> String {
        "\u{001B}[0;31m" + self + "\u{001B}[0;39m"
    }

    public func formattedUnderlined() -> String {
        "\u{001b}[4m" + self + "\u{001B}[0;39m"
    }

    /// Breaks the receiver on the specified delimiter to form lines of the given length. The line length
    /// cannot be guaranteed and may be exceeded if the receiver doesn't allow otherwise.
    func toFuzzyLines(ofLength lineLength: Int, breakingOn delimiter: String) -> [String] {
        var buffer = self
        var lines = [String]()
        while !buffer.isEmpty {
            let breakingIndex: String.Index
            if buffer.count < lineLength {
                breakingIndex = buffer.endIndex
            } else {
                let lineRange = Range(uncheckedBounds: (buffer.startIndex, buffer.index(buffer.startIndex, offsetBy: lineLength)))
                var delimiterRange = buffer.range(of: delimiter, options: .backwards, range: lineRange)
                if delimiterRange == nil {
                    let remainderRange = Range(uncheckedBounds: (buffer.index(buffer.startIndex, offsetBy: lineLength), buffer.endIndex))
                    delimiterRange = buffer.range(of: delimiter, range: remainderRange)
                }
                breakingIndex = delimiterRange?.lowerBound ?? buffer.endIndex
            }
            lines.append(String(buffer[..<breakingIndex]))
            if breakingIndex == buffer.endIndex {
                buffer = ""
            } else {
                buffer = String(buffer[buffer.index(breakingIndex, offsetBy: delimiter.count)...])
            }
        }
        return lines
    }

    /// Pads the receiver with trailing whitespace to match the specified output width
    func toWidth(_ width: Int) -> String {
        return String(format: "%\(width)-s", (self as NSString).utf8String!)
    }

    public func ky_data(using encoding: String.Encoding, allowLossyConversion: Bool = false) throws -> Data {
        guard let data = self.data(using: encoding, allowLossyConversion: allowLossyConversion) else {
            throw NSError(description: "Could not create data from string")
        }
        return data
    }

}
