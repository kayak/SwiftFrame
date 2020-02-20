import Foundation

extension FileManager {

    @discardableResult func ky_isWritableDirectory(atPath path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        // Will be nil if directory is nil, in that case traverse up the file system to find last accessible folder
        guard let permissions = try? attributesOfItem(atPath: url.path)[.posixPermissions] as? Int16 else {
            return ky_isWritableDirectory(atPath: url.deletingLastPathComponent().path)
        }

        return getPosixPermissionsForUser(permissions)?.canWrite ?? false
    }

    func filesAtPath(_ url: URL, with pathExtension: String, skipsHiddenFiles: Bool = true) throws -> [URL] {
        return try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? [.skipsHiddenFiles] : [])
            .filter { $0.pathExtension == pathExtension }
    }

    private func getPosixPermissionsForUser(_ permissions: Int16) -> PosixGroup? {
        let octalString = String(permissions, radix: 0o10)
        guard let octalInt = Int16(octalString) else {
            return nil
        }

        let remainder = octalInt % 100
        let userPermissionCode = (octalInt - remainder) / 100
        return PosixGroup(octalCode: userPermissionCode)
    }

}
