import Foundation

extension Array where Element == URL {

    func filter(pattern: String?) throws -> Self {
        guard let pattern = pattern else {
            return self
        }
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            throw NSError(description: "Invalid regular expression: \"\(pattern)\"")
        }
        return self.filter { url in
            let lastComponent = url.deletingPathExtension().lastPathComponent
            return regex.matches(lastComponent)
        }
    }

}

extension NSRegularExpression {

    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }

}
