import Foundation

extension Array where Element == URL {

    func filterByFileOrFoldername(regex: NSRegularExpression?) throws -> Self {
        guard let regex = regex else {
            return self
        }
        return self.filter { url in
            let lastComponent = url.deletingPathExtension().lastPathComponent
            return regex.matches(lastComponent)
        }
    }

}

extension NSRegularExpression {

    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: (string as NSString).length)
        return firstMatch(in: string, options: [], range: range) != nil
    }

}
