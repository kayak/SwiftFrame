import Foundation

extension FileManager {

    @discardableResult func ky_isWritableDirectory(atPath path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        // Will be nil if directory is nil, in that case traverse up the file system to find last accessible folder
        guard let permissions = try? attributesOfItem(atPath: url.path)[.posixPermissions] as? Int16 else {
            return ky_isWritableDirectory(atPath: url.deletingLastPathComponent().path)
        }
        return permissions == 493 && url.pathExtension.isEmpty
    }

    func filesAtPath(_ url: URL, with pathExtension: String, skipsHiddenFiles: Bool = true) throws -> [URL] {
        return try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? [.skipsHiddenFiles] : [])
            .filter { $0.pathExtension == pathExtension }
    }

}
