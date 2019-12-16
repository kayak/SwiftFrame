import AppKit
import Foundation

let kScreenshotExtensions = Set<String>(arrayLiteral: "png", "jpg", "jpeg")

// MARK: - Config Loading & Path Mapping

private func loadConfig(path: String?) throws -> ConfigFile {
    guard let path = path else {
        throw NSError(description: "No config file path was found")
    }
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(ConfigFile.self, from: data)
}

private func pathRelativeToFile(_ path: String, fragment: String) -> String {
    var components = (path as NSString).pathComponents
    components.removeLast()
    components.append(contentsOf: (fragment as NSString).pathComponents)
    return NSString.path(withComponents: components) as String
}

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
            print(CommandLineFormatter().formatWarning("No matching frame for screenshot \(path)"))
            continue
        }
        var paths = result[frame] ?? []
        paths.append(path)
        result[frame] = paths
    }
    return result
}

// MARK: - Numeric Component Parsing

private class NumericComponentsParser {

    func rect(from string: String) throws -> NSRect {
        let components = try intComponents(from: string, count: 4)
        return NSRect(x: components[0], y: components[1], width: components[2] - components[0], height: components[3] - components[1])
    }

    func edgeInsets(from string: String) throws -> NSEdgeInsets {
        let components = try intComponents(from: string, count: 4)
        return NSEdgeInsets(top: CGFloat(components[0]), left: CGFloat(components[1]), bottom: CGFloat(components[2]), right: CGFloat(components[3]))
    }

    private func intComponents(from string: String, count: Int) throws -> [Int] {
        let stringComponents = string.components(separatedBy: .whitespaces)
        guard stringComponents.count == count else {
            throw NSError(description: "Failed to parse numeric components from \(string)")
        }
        let intComponents = stringComponents.compactMap { Int($0) }
        guard intComponents.count == stringComponents.count else {
            throw NSError(description: "Failed to parse numeric components from \(string)")
        }
        return intComponents
    }

}
