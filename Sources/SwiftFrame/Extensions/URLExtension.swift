import AppKit
import Foundation

extension URL {
    var subDirectories: [URL] {
        guard hasDirectoryPath else {
            print("is not directory")
            return []
        }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.hasDirectoryPath }) ?? []
    }

    var bitmapRep: NSBitmapImageRep? {
        guard let data = try? Data(contentsOf: self) else {
            return nil
        }
        return NSBitmapImageRep(data: data)
    }
}