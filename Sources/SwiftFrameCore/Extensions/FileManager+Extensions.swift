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

    func ky_clearDirectories(_ urls: [FileURL], localeFolders: [String]) throws {
        try urls.forEach { url in
            let mappedURLs = localeFolders.map { url.absoluteURL.appendingPathComponent($0) }
            try mappedURLs.forEach {
                let contents = try contentsOfDirectory(at: $0, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                try contents.forEach {
                    try removeItem(at: $0)
                }
            }
        }
    }

}
