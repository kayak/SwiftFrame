import Foundation

extension FileManager {

    func ky_filesAtPath(_ url: URL, with pathExtension: String? = nil) throws -> [URL] {
        try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            .filter { pathExtension == nil ? true : $0.pathExtension == pathExtension }
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

    public func ky_writeToFile(_ contents: String, destination: URL) throws {
        guard let data = contents.data(using: .utf8) else {
            throw NSError(description: "Could not encode string using UTF-8")
        }
        try ky_createFile(atURL: destination, contents: data, attributes: nil)
    }

    public func ky_createFile(atURL url: URL, contents: Data?, attributes: [FileAttributeKey : Any]? = nil) throws {
        try ky_createFile(atPath: url.path, contents: contents, attributes: attributes)
    }

    public func ky_createFile(atPath path: String, contents: Data?, attributes: [FileAttributeKey : Any]? = nil) throws {
        if !createFile(atPath: path, contents: contents, attributes: attributes) {
            throw NSError(description: "Could not create file at path \(path)")
        }
    }

}
