import AppKit
import Foundation

extension String {

    func registerFont(at size: CGFloat = 20) throws -> NSFont {
        let fontName = try FontRegistry.shared.registerFont(atPath: self)
        guard let font = NSFont(name: fontName, size: size) else {
            throw NSError(description: "Failed to load title font with name \(fontName)")
        }
        return font
    }

    private func pathRelativeToFile(_ path: String, fragment: String) -> String {
        var components = (path as NSString).pathComponents
        components.removeLast()
        components.append(contentsOf: (fragment as NSString).pathComponents)
        return NSString.path(withComponents: components) as String
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

}
