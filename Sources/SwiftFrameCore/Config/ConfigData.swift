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

    let stringsPath: FileURL
    let maxFontSize: CGFloat
    let outputPaths: [FileURL]
    let fontSource: FontSource
    let textColorSource: ColorSource
    let outputFormat: FileFormat
    let localesRegex: String?

    @DecodableDefault.True var clearDirectories: Bool
    @DecodableDefault.False var outputWholeImage: Bool
    @DecodableDefault.EmptyList var textGroups: [TextGroup]

    internal private(set) var deviceData: [DeviceData]
    internal private(set) var titles = LocalizedStringFiles()

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case clearDirectories
        case outputWholeImage
        case deviceData
        case textGroups
        case stringsPath
        case maxFontSize
        case outputPaths
        case fontSource = "fontFile"
        case textColorSource = "textColor"
        case outputFormat = "format"
        case localesRegex = "locales"
    }

    // MARK: - Init

    public init(
        textGroups: [TextGroup] = [],
        stringsPath: FileURL,
        maxFontSize: CGFloat,
        outputPaths: [FileURL],
        fontSource: FontSource,
        textColorSource: ColorSource,
        outputFormat: FileFormat,
        clearDirectories: Bool,
        outputWholeImage: Bool,
        deviceData: [DeviceData],
        localesRegex: String? = nil)
    {
        self.textGroups = textGroups
        self.stringsPath = stringsPath
        self.maxFontSize = maxFontSize
        self.outputPaths = outputPaths
        self.fontSource = fontSource
        self.textColorSource = textColorSource
        self.outputFormat = outputFormat
        self.clearDirectories = clearDirectories
        self.outputWholeImage = outputWholeImage
        self.deviceData = deviceData
        self.localesRegex = localesRegex
    }

    // MARK: - Processing

    mutating public func process() throws {
        let regex: NSRegularExpression?
        if let pattern = localesRegex {
            regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        } else {
            regex = nil
        }

        deviceData = try deviceData.map { try $0.makeProcessedData(localesRegex: regex) }

        let textFiles = try FileManager.default.ky_filesAtPath(stringsPath.absoluteURL, with: "strings").filterByFileOrFoldername(regex: regex)
        let strings = textFiles.compactMap { NSDictionary(contentsOf: $0) as? [String: String] }
        titles = Dictionary(uniqueKeysWithValues: zip(textFiles.map({ $0.fileName }), strings))
    }

    // MARK: - ConfigValidatable

    public func validate() throws {
        guard !deviceData.isEmpty else {
            throw NSError(
                description: "No screenshot data was supplied",
                expectation: "Please supply at least one screenshot along with metadata")
        }

        guard !outputPaths.isEmpty else {
            throw NSError(
                description: "No output paths were specified",
                expectation: "Please specify at least one output directory")
        }

        try deviceData.forEach { try $0.validate() }
    }

    public func printSummary(insetByTabs tabs: Int) {
        ky_print("### Config Summary Start", insetByTabs: tabs)
        CommandLineFormatter.printKeyValue("Outputs whole image as well in addition to slices", value: outputWholeImage)
        CommandLineFormatter.printKeyValue("Title Color", value: textColorSource.hexString, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Title Font", value: try? fontSource.font().fontName, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Title Max Font Size", value: maxFontSize, insetBy: tabs)
        CommandLineFormatter.printKeyValue(
            "String Files",
            value: titles.isEmpty ? "none" : titles.keys.joined(separator: ", "),
            insetBy: tabs)

        ky_print("Output paths:", insetByTabs: tabs)
        outputPaths.forEach { ky_print($0.path.formattedGreen(), insetByTabs: tabs + 1) }

        ky_print("Device data:", insetByTabs: tabs)
        deviceData.forEach {
            $0.printSummary(insetByTabs: tabs + 1)
            print()
        }

        if !textGroups.isEmpty {
            print("Text groups:")
            textGroups.forEach {
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
        return try textGroups.reduce(into: [String: CGFloat]()) { dictionary, group in
            let strings = associatedStrings.filter({ $0.data.groupIdentifier == group.identifier })
            dictionary[group.identifier] = try group.sharedFontSize(
                with: strings,
                globalFont: try fontSource.font(),
                globalMaxSize: maxFontSize)
        }
    }

}
