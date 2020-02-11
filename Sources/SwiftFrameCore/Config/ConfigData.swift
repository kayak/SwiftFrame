import Foundation
import AppKit

public protocol ConfigValidatable {
    func validate() throws
    func printSummary(insetByTabs tabs: Int)
}

var verbose = false

/// First key is locale, second is regular key in string file
public typealias LocalizedStringFiles = [String : [String : String]]

public struct ConfigData: Decodable, ConfigValidatable {

    // MARK: - Properties

    public let outputWholeImage: Bool
    public let textGroups: [TextGroup]?
    public let stringsPath: LocalURL
    public let maxFontSize: CGFloat
    public let outputPaths: [LocalURL]
    public let fontPath: String
    public let textColorString: String

    public private(set) var deviceData: [DeviceData]
    public private(set) var font: NSFont!
    public private(set) var textColor: NSColor!
    public private(set) var titles = LocalizedStringFiles()

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case outputWholeImage
        case deviceData
        case textGroups
        case stringsPath
        case maxFontSize
        case outputPaths
        case fontPath = "fontFile"
        case textColorString = "textColor"
    }

    // MARK: - Init

    public init(
        outputWholeImage: Bool = true,
        textGroups: [TextGroup]?,
        stringsPath: LocalURL,
        maxFontSize: CGFloat,
        outputPaths: [LocalURL],
        fontPath: String,
        textColorString: String,
        deviceData: [DeviceData],
        font: NSFont,
        textColor: NSColor,
        titles: LocalizedStringFiles = LocalizedStringFiles())
    {
        self.outputWholeImage = outputWholeImage
        self.textGroups = textGroups
        self.stringsPath = stringsPath
        self.maxFontSize = maxFontSize
        self.outputPaths = outputPaths
        self.fontPath = fontPath
        self.textColorString = textColorString
        self.deviceData = deviceData
        self.font = font
        self.textColor = textColor
        self.titles = titles
    }

    // MARK: - Processing

    mutating public func process() throws {
        deviceData = try deviceData.map { try $0.makeProcessedData() }

        if font == nil {
            font = try FontRegistry.shared.registerFont(atPath: fontPath)
        }
        textColor = try NSColor(hexString: textColorString)

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
        print("### Config Summary Begin")
        CommandLineFormatter.printKeyValue("Outputs whole image as well as slices", value: outputWholeImage)
        CommandLineFormatter.printKeyValue("Title Color", value: textColor.hexString, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Title Font", value: font.fontName, insetBy: tabs)
        CommandLineFormatter.printKeyValue("Title Max Font Size", value: maxFontSize, insetBy: tabs)
        CommandLineFormatter.printKeyValue("String Files", value: titles.count, insetBy: tabs)

        print("Output paths:")
        outputPaths.forEach { print($0.absoluteString.formattedGreen(), insetByTabs: tabs + 1) }

        print("Device data:")
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

    public func run(_ _verbose: Bool) throws {
        verbose = _verbose

        try deviceData.forEach { device in
            try device.screenshots.forEach { locale, imageDict in
                print("\(device.outputSuffix) - \(locale)".formattedUnderlined())

                guard let sliceSize = imageDict.first?.value.nativeSize else {
                    throw NSError(description: "No screenshots supplied, so it's impossible to slice into the correct size")
                }

                print("Rendering screenshots")

                let composer = try ImageComposer(canvasSize: device.templateImage.nativeSize)
                try composer.add(screenshots: imageDict, with: device.screenshotData, for: locale)
                try composer.addTemplateImage(device.templateImage)

                print("Rendering text titles")

                let processedStrings = try makeAssociatedStrings(for: device, locale: locale)
                try composer.addStrings(
                    processedStrings.strings,
                    maxFontSizeByGroup: processedStrings.fontSizes,
                    font: font,
                    color: textColor,
                    maxFontSize: maxFontSize)

                try composer.finish(with: outputPaths, sliceSize: sliceSize, outputWholeImage: outputWholeImage, locale: locale, suffix: device.outputSuffix)

                print("Done\n")
            }
        }
    }

    private func makeAssociatedStrings(for device: DeviceData, locale: String) throws -> (strings: [AssociatedString], fontSizes: [String: CGFloat]) {
        let constructedTitles: [AssociatedString] = try device.textData.map {
            guard let title = titles[locale]?[$0.titleIdentifier] else {
                throw NSError(description: "Title with key \"\($0.titleIdentifier)\" not found in string file \"\(locale)\"")
            }
            return (title, $0)
        }

        let maxFontSizeByGroup = textGroups?.reduce(into: [String: CGFloat]()) { dictionary, group in
            let strings = constructedTitles.filter({ $0.data.groupIdentifier == group.identifier })
            dictionary[group.identifier] = group.sharedFontSize(
                with: strings,
                globalFont: font,
                globalMaxSize: maxFontSize)
            } ?? [:]

        return (strings: constructedTitles, fontSizes: maxFontSizeByGroup)
    }

}
