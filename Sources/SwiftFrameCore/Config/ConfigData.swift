import Foundation
import AppKit

protocol ConfigValidatable {
    func validate() throws
    func printSummary(insetByTabs tabs: Int)
}

/// First key is locale, second is regular key in string file
typealias LocalizedStringFiles = [String : [String : String]]

struct ConfigData: Decodable, ConfigValidatable {

    // MARK: - Properties

    let outputWholeImage: Bool
    let textGroups: [TextGroup]?
    let stringsPath: LocalURL
    let maxFontSize: CGFloat
    let outputPaths: [LocalURL]
    let fontSource: FontSource
    let textColorSource: ColorSource

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
    }

    // MARK: - Processing

    mutating public func process() throws {
        deviceData = try deviceData.map { try $0.makeProcessedData() }

        _ = try fontSource.makeFont()

        var parsedTitles = LocalizedStringFiles()
        let textFiles = try FileManager.default.contentsOfDirectory(at: stringsPath.absoluteURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            .filter { $0.pathExtension == "strings" }
        textFiles.forEach { textFile in
            parsedTitles[textFile.absoluteURL.fileName] = NSDictionary(contentsOf: textFile) as? [String: String]
        }
        titles = parsedTitles
    }

    // MARK: - ConfigValidatable

    public func validate() throws {
        guard !deviceData.isEmpty else {
            throw NSError(description: "No screenshot data was supplied")
        }

        try deviceData.forEach { try $0.validate() }
    }

    public func printSummary(insetByTabs tabs: Int) {
        print("### Config Summary Begin", insetByTabs: 0)
        CommandLineFormatter.printKeyValue("Outputs whole image as well as slices", value: outputWholeImage)
        CommandLineFormatter.printKeyValue("Title Color", value: textColorSource.hexString, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Title Font", value: try? fontSource.makeFont().fontName, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Title Max Font Size", value: maxFontSize, insetBy: tabs)
        CommandLineFormatter.printKeyValue("String Files", value: titles.count, insetBy: tabs)

        print("Output paths:", insetByTabs: 0)
        outputPaths.forEach { print($0.absoluteString.formattedGreen(), insetByTabs: tabs + 1) }

        print("Device data:", insetByTabs: 0)
        deviceData.forEach {
            $0.printSummary(insetByTabs: tabs + 1)
            print("")
        }

        if let groups = textGroups, !groups.isEmpty {
            print("Text groups:")
            groups.forEach {
                $0.printSummary(insetByTabs: tabs + 1)
                print("")
            }
        } else {
            print("No implicit text groups defined, using global max font size\n")
        }

        print("### Config Summary End")
    }

    // MARK: - Screenshot Factory

    func makeAssociatedStrings(for device: DeviceData, locale: String) throws -> (strings: [AssociatedString], fontSizes: [String: CGFloat]) {
        let constructedTitles: [AssociatedString] = try device.textData.map {
            guard let title = titles[locale]?[$0.titleIdentifier] else {
                throw NSError(description: "Title with key \"\($0.titleIdentifier)\" not found in string file \"\(locale)\"")
            }
            return (title, $0)
        }

        let maxFontSizeByGroup = try textGroups?.reduce(into: [String: CGFloat]()) { dictionary, group in
            let strings = constructedTitles.filter({ $0.data.groupIdentifier == group.identifier })
            dictionary[group.identifier] = group.sharedFontSize(
                with: strings,
                globalFont: try fontSource.makeFont(),
                globalMaxSize: maxFontSize)
            } ?? [:]

        return (strings: constructedTitles, fontSizes: maxFontSizeByGroup)
    }

}
