import Foundation
import AppKit

protocol ConfigValidatable {
    func validate() throws
    func printSummary(insetByTabs tabs: Int)
}

/// First key is locale, second is regular key in string file
typealias LocalizedStringFiles = [String: [String: String]]

struct ConfigData: Decodable, ConfigValidatable {

    // MARK: - Properties

    let outputWholeImage: Bool
    let textGroups: [TextGroup]?
    let stringsPath: FileURL
    let maxFontSize: CGFloat
    let outputPaths: [FileURL]
    let fontSource: FontSource
    let textColorSource: ColorSource
    let outputFormat: FileFormat

    internal private(set) var deviceData: [DeviceData]
    internal private(set) var titles = LocalizedStringFiles()

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case outputWholeImage
        case deviceData
        case textGroups
        case stringsPath
        case maxFontSize
        case outputPaths
        case fontSource = "fontFile"
        case textColorSource = "textColor"
        case outputFormat = "format"
    }

    // MARK: - Processing

    mutating public func process() throws {
        deviceData = try deviceData.map { try $0.makeProcessedData() }

        let textFiles = try FileManager.default.filesAtPath(stringsPath.absoluteURL, with: "strings")
        let strings = textFiles.compactMap { NSDictionary(contentsOf: $0) as? [String: String] }
        titles = Dictionary(uniqueKeysWithValues: zip(textFiles.map({ $0.fileName }), strings))
    }

    // MARK: - ConfigValidatable

    public func validate() throws {
        guard !deviceData.isEmpty else {
            throw NSError(description: "No screenshot data was supplied")
        }

        guard !outputPaths.isEmpty else {
            throw NSError(description: "No output paths were specified")
        }

        try outputPaths.forEach {
            guard FileManager.default.ky_isWritableDirectory(atPath: $0.path) else {
                throw NSError(description: "The specified path \($0.path) is a file or a non-writable directory")
            }
        }

        try deviceData.forEach { try $0.validate() }
    }

    public func printSummary(insetByTabs tabs: Int) {
        print("### Config Summary Begin", insetByTabs: tabs)
        CommandLineFormatter.printKeyValue("Outputs whole image as well as slices", value: outputWholeImage)
        CommandLineFormatter.printKeyValue("Title Color", value: textColorSource.hexString, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Title Font", value: try? fontSource.font().fontName, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Title Max Font Size", value: maxFontSize, insetBy: tabs)
        CommandLineFormatter.printKeyValue("String Files", value: titles.count, insetBy: tabs)

        print("Output paths:", insetByTabs: tabs)
        outputPaths.forEach { print($0.path.formattedGreen(), insetByTabs: tabs + 1) }

        print("Device data:", insetByTabs: tabs)
        deviceData.forEach {
            $0.printSummary(insetByTabs: tabs + 1)
            print()
        }

        if let groups = textGroups, !groups.isEmpty {
            print("Text groups:")
            groups.forEach {
                $0.printSummary(insetByTabs: tabs + 1)
                print()
            }
        } else {
            print("No implicit text groups defined, using global max font size\n")
        }

        print("### Config Summary End")
    }

    // MARK: - Screenshot Factory

    func makeAssociatedStrings(for device: DeviceData, locale: String) throws -> [AssociatedString] {
        return try device.textData.map {
            guard let title = titles[locale]?[$0.titleIdentifier] else {
                throw NSError(description: "Title with key \"\($0.titleIdentifier)\" not found in string file \"\(locale)\"")
            }
            return (title, $0)
        }
    }

    func makeSharedFontSizes(for associatedStrings: [AssociatedString]) throws -> [String: CGFloat] {
        return try textGroups?.reduce(into: [String: CGFloat]()) { dictionary, group in
            let strings = associatedStrings.filter({ $0.data.groupIdentifier == group.identifier })
            dictionary[group.identifier] = group.sharedFontSize(
                with: strings,
                globalFont: try fontSource.font(),
                globalMaxSize: maxFontSize)
        } ?? [:]
    }

}
