import AppKit
import Foundation

let kScreenshotExtensions = Set<String>(arrayLiteral: "png", "jpg", "jpeg")

// MARK: - Screenshot Path Parsing

private func parseScreenshotPaths(folderPath: String, outputSuffix: String?) throws -> [String] {
    return (try FileManager.default.contentsOfDirectory(atPath: folderPath))
        .filter { path in
            if let suffix = outputSuffix, (path as NSString).deletingPathExtension.hasSuffix(suffix) {
                return false
            }
            return kScreenshotExtensions.contains((path as NSString).pathExtension.lowercased())
        }
        .map { (folderPath as NSString).appendingPathComponent($0) }
        .sorted()
}

private func groupScreenshotPaths(_ screenshotPaths: [String], frames: [Frame]) -> [Frame: [String]] {
    var result: [Frame: [String]] = [:]
    for path in screenshotPaths {
        guard let frame = frames.first(where: { $0.matches(path: path) }) else {
            print(CommandLineFormatter.formatWarning("No matching frame for screenshot \(path)"))
            continue
        }
        var paths = result[frame] ?? []
        paths.append(path)
        result[frame] = paths
    }
    return result
}
