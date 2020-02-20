import AppKit
import Foundation

extension URL {

    var fileName: String {
        var components = lastPathComponent.components(separatedBy: ".")
        components.removeLast(1)
        return components.joined(separator: ".")
    }

    var bitmapImageRep: NSBitmapImageRep? {
        ImageLoader.loadRepresentation(at: self)
    }

    var subDirectories: [URL] {
        guard hasDirectoryPath else {
            return []
        }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter { $0.hasDirectoryPath }) ?? []
    }

}
