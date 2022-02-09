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

extension Collection {

    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }

}
