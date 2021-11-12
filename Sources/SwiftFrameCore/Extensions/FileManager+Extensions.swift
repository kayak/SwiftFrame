import Foundation

extension FileManager {

    func ky_filesAtPath(_ url: URL, with pathExtension: String? = nil) throws -> [URL] {
        try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            .filter { pathExtension == nil ? true : $0.pathExtension == pathExtension }
    }

    // Doesn't throw if the directory doesn't exist or another error occured
    func ky_unsafeFilesAtPath(_ url: URL) -> [URL] {
        do {
            return try ky_filesAtPath(url)
        } catch {
            return []
        }
    }

    func ky_subDirectoriesAtPath(_ url: URL) -> [URL] {
        guard let urls = try? contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else {
            return []
        }
        return urls.filter { $0.hasDirectoryPath }
    }

    func ky_clearDirectories(_ urls: [FileURL], localeFolders: [String]) throws {
        try urls.forEach { url in
            let mappedURLs: [URL] = localeFolders.compactMap {
                let mappedURL = url.absoluteURL.appendingPathComponent($0)
                return fileExists(atPath: mappedURL.path) ? mappedURL : nil
            }
            try mappedURLs.forEach {
                try removeItem(at: $0)
            }
        }
    }

}
