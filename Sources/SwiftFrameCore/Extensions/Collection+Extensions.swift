import Foundation

extension [URL] {

    func filterByFileOrFoldername(regex: Regex<AnyRegexOutput>?) throws -> Self {
        guard let regex else {
            return self
        }
        return self.filter { url in
            let lastComponent = url.deletingPathExtension().lastPathComponent
            return !lastComponent.matches(of: regex).isEmpty
        }
    }

}
