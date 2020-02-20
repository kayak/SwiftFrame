import Foundation

extension FileManager {

    // We could use `FileManager.default.isWritableFile` here but that will return false in any case when
    // the target directory does not exist yet
    @discardableResult func ky_isWritableDirectory(atPath path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        guard url.pathExtension.isEmpty else {
            return false
        }

        do {
            let fileURL = url.appendingPathComponent(".ky_tmp")
            let bytes = try "directory is writable".ky_data(using: .utf8)
            try bytes.ky_write(to: fileURL)
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch {
            return false
        }
    }

    func filesAtPath(_ url: URL, with pathExtension: String, skipsHiddenFiles: Bool = true) throws -> [URL] {
        return try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? [.skipsHiddenFiles] : [])
            .filter { $0.pathExtension == pathExtension }
    }

}
