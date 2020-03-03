import AppKit
import Foundation

extension URL {

    var fileName: String {
        return deletingPathExtension().lastPathComponent
    }

    var subDirectories: [URL] {
        guard hasDirectoryPath else {
            return []
        }
        return FileManager.default.ky_subDirectoriesAtPath(self)
    }

}
