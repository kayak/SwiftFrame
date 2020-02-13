import AppKit
import Foundation
import CoreGraphics
import CoreImage

final class ImageComposer: VerbosePrintable {

    // MARK: - Properties

    private let textRenderer = TextRenderer()
    private let screenshotRenderer = ScreenshotRenderer()
    var verbose: Bool

    let context: CGContext

    // MARK: - Init

    init(canvasSize: CGSize, verbose: Bool) throws {
        self.context = try ImageComposer.createContext(size: canvasSize)
        self.verbose = verbose
    }

    // MARK: - Preparation

    private static func createContext(size: CGSize) throws -> CGContext {
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else {
            throw NSError(description: "Failed to create graphics context")
        }
        return context
    }

    // MARK: - Composition

    func addTemplateImage(_ image: NSBitmapImageRep) throws {
        guard let templateImage = image.cgImage else {
            throw NSError(description: "Could not render template image")
        }

        context.saveGState()
        defer { context.restoreGState() }

        context.draw(templateImage, in: image.nativeRect)
    }

    // MARK: - Titles Rendering

    func addStrings(_ associatedStrings: [AssociatedString], maxFontSizeByGroup: [String: CGFloat], font: NSFont, color: NSColor, maxFontSize: CGFloat) throws {
        try associatedStrings.forEach {
            print("we ended up here")
            if let sharedSize = $0.data.groupIdentifier.flatMap({ maxFontSizeByGroup[$0] }) {
                // Can use fixed font size since common maximum has already been calculated
                try add(
                    title: $0.string,
                    font: $0.data.fontOverride?.makeFont() ?? font,
                    color: $0.data.textColorOverride ?? color,
                    fixedFontSize: sharedSize,
                    textData: $0.data)

                printVerbose(
                    "Rendered title with identifier \"\($0.data.titleIdentifier)\" with font size \(Int(sharedSize))".formattedGreen(),
                    insetByTabs: 1)
            } else {
                let renderedFontsize = try add(
                    title: $0.string,
                    font: $0.data.fontOverride?.makeFont() ?? font,
                    color: $0.data.textColorOverride ?? color,
                    maxFontSize: $0.data.maxFontSizeOverride ?? maxFontSize,
                    textData: $0.data)

                printVerbose(
                    "Rendered title with identifier \"\($0.data.titleIdentifier)\" with font size \(Int(renderedFontsize))".formattedGreen(),
                    insetByTabs: 1)
            }
        }

        print("end of strings body")
    }

    private func add(title: String, font: NSFont, color: NSColor, maxFontSize: CGFloat, textData: TextData) throws -> CGFloat {
        let fontSize = try textRenderer.maximumFontSizeThatFits(
            string: title,
            font: font,
            alignment: textData.textAlignment,
            maxSize: maxFontSize,
            size: textData.rect.size)
        let adaptedFont = font.toFont(ofSize: fontSize)
        try textRenderer.render(text: title, font: adaptedFont, color: color, alignment: textData.textAlignment, rect: textData.rect, context: context)
        return fontSize
    }

    private func add(title: String, font: NSFont, color: NSColor, fixedFontSize: CGFloat, textData: TextData) throws {
        let adaptedFont = font.toFont(ofSize: fixedFontSize)
        try textRenderer.render(text: title, font: adaptedFont, color: color, alignment: textData.textAlignment, rect: textData.rect, context: context)
    }

    // MARK: - Screenshots Rendering

    func add(screenshots: [String: URL], with screenshotData: [ScreenshotData], for locale: String) throws {
        try screenshotData.forEach { data in
            guard let image = screenshots[data.screenshotName]?.bitmapImageRep else {
                throw NSError(description: "Screenshot named \(data.screenshotName) not found in folder \"\(locale)\"")
            }
            try add(screenshot: image, with: data)

            printVerbose("Rendered screenshot \(data.screenshotName)".formattedGreen(), insetByTabs: 1)
        }
    }

    func add(screenshot: NSBitmapImageRep, with data: ScreenshotData) throws {
        try screenshotRenderer.render(screenshot: screenshot, with: data, in: context)
    }

}
