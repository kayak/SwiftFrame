import Foundation

extension FileManager {

    func ky_filesAtPath(_ url: URL, with pathExtension: String) throws -> [URL] {
        return try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).filter { $0.pathExtension == pathExtension }
    }

    func ky_subDirectoriesAtPath(_ url: URL) -> [URL] {
        guard let urls = try? contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else {
            return []
        }
        return urls.filter { $0.hasDirectoryPath }
    }

}
