import AppKit
import Foundation

extension Data {

    func ky_write(to url: URL, options: Data.WritingOptions = []) throws {
        guard url.isFileURL else {
            throw NSError(description: "The specified URL \(url.absoluteString) is not a file")
        }

        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
        try self.write(to: url, options: options)
    }

}
