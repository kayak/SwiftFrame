import Foundation

extension FileManager {

    func filesAtPath(_ url: URL, with pathExtension: String, skipsHiddenFiles: Bool = true) throws -> [URL] {
        return try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? [.skipsHiddenFiles] : [])
            .filter { $0.pathExtension == pathExtension }
    }

}
