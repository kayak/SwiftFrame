import AppKit
import Foundation

let kScreenshotExtensions = Set<String>(arrayLiteral: "png", "jpg", "jpeg")

// MARK: - Config

final class Config {

    let verbose: Bool

    let titleTexts: [String]
    let titleColor: NSColor
    let titleFont: NSFont

    let screenshotPathsByFrame: [Frame: [String]]
    let templatePathsByFrame: [Frame: URL]
    let outputPathsByScreenshotPath: [String: String]

    // MARK: - Object Lifecycle

    init(options: CommandLineOptions) throws {
        let configPath = options.configPath.arguments.first
        let configJSON = try loadConfigJSON(path: configPath)

        verbose = options.verbose.isSpecified

        guard let background = try parseBackground(configJSON: configJSON, options: options) else {
            throw NSError(description: "Missing or invalid background specification")
        }
        self.background = background

        titleTexts = try parseTitleTexts(options: options)
        guard !titleTexts.isEmpty else {
            throw NSError(description: "Missing or invalid title text specification")
        }

        let frames = try parseFrames(configPath: configPath, configJSON: configJSON, options: options)
        guard !frames.isEmpty else {
            throw NSError(description: "Missing or invalid frame specification")
        }

        let outputSuffix = parseOutputSuffix(configJSON: configJSON, options: options)

        let screenshotPaths = try parseScreenshotPaths(options: options, outputSuffix: outputSuffix)
        guard !screenshotPaths.isEmpty else {
            throw NSError(description: "No screenshots specified")
        }

        screenshotPathsByFrame = groupScreenshotPaths(screenshotPaths, frames: frames)
        for paths in screenshotPathsByFrame.values {
            guard paths.count == titleTexts.count else {
                throw NSError(description: "Unbalanced number of screenshots and title texts.\nScreenshots: \(paths)\nTitles: \(titleTexts)")
            }
        }

        outputPathsByScreenshotPath = parseOutputPaths(configJSON: configJSON, options: options, outputSuffix: outputSuffix, screenshotPaths: screenshotPaths)
        guard !outputPathsByScreenshotPath.isEmpty else {
            throw NSError(description: "Invalid output path specification")
        }
    }

    // MARK: - Summary

    func printSummary() {
        print("### Config Summary Begin")
        //print("Background: \(background)")
        for (index, text) in titleTexts.enumerated() {
            print("Title Text #\(index + 1): \"\(text)\"")
        }
        print("Title Color: \(titleColor.hexString)")
        print("Title Font: \(titleFont.fontName)")
        //print("Title Padding: \(titlePadding)")
        for (index, element) in screenshotPathsByFrame.enumerated() {
            print("Frame #\(index + 1) Path: \(element.key.path)")
            print("Frame #\(index + 1) Viewport: \(element.key.viewport)")
            print("Frame #\(index + 1) Padding: \(element.key.padding)")
            for (screenshotIndex, path) in element.value.enumerated() {
                print("Frame #\(index + 1) Screenshot #\(screenshotIndex + 1): \(path)")
            }
        }
        print("### Config Summary End")
    }

}

// MARK: - Config Loading & Path Mapping

private func loadConfigJSON(path: String?) throws -> [String: Any] {
    guard let path = path else {
        return [:]
    }
    let url = URL(fileURLWithPath: path)
    let data = try Data(contentsOf: url)
    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
        throw NSError(description: "Could not parse config under \(path)")
    }
    return json
}

private func pathRelativeToFile(_ path: String, fragment: String) -> String {
    var components = (path as NSString).pathComponents
    components.removeLast()
    components.append(contentsOf: (fragment as NSString).pathComponents)
    return NSString.path(withComponents: components) as String
}

// MARK: - Title Font Parsing

private func parseTitleFontPath(configPath: String?, configJSON: [String: Any], options: CommandLineOptions) -> String? {
    guard
        let configPath = configPath,
        let titlesObject = configJSON["titles"] as? [String: Any],
        let fontPath = titlesObject["font"] as? String
    else {
        return options.titleFontPath.arguments.first
    }
    return fontPath.hasPrefix("/") ? fontPath : pathRelativeToFile(configPath, fragment: fontPath)
}

private func parseTitleFont(configPath: String?, configJSON: [String: Any], options: CommandLineOptions) throws -> NSFont? {
    guard let fontPath = parseTitleFontPath(configPath: configPath, configJSON: configJSON, options: options) else {
        return nil
    }
    let fontName = try FontRegistry().registerFont(atPath: fontPath)
    guard let font = NSFont(name: fontName, size: 20) else {
        throw NSError(description: "Failed to load title font with name \(fontName)")
    }
    return font
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
