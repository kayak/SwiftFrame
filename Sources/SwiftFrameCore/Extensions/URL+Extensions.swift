import AppKit
import Foundation

extension URL {

    var fileName: String {
        var components = lastPathComponent.components(separatedBy: ".")
        components.removeLast(1)
        return components.joined(separator: ".")
    }

    var subDirectories: [URL] {
        guard hasDirectoryPath else {
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
