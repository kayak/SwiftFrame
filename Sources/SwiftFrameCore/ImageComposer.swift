import AppKit
import Foundation
import CoreGraphics
import CoreImage

public final class ImageComposer {

    // MARK: - Properties

    public let textRenderer = TextRenderer()
    private let screenshotRenderer = ScreenshotRenderer()
    private let context: CGContext

    // MARK: - Init

    public init(canvasSize: CGSize) throws {
        self.context = try ImageComposer.createContext(size: canvasSize)
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

    public func addTemplateImage(_ image: NSBitmapImageRep) throws {
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
            if let sharedSize = maxFontSizeByGroup[safe: $0.data.groupIdentifier] {
                // Can use fixed font size since common maximum has already been calculated
                try add(
                    title: $0.string,
                    font: $0.data.fontOverride ?? font,
                    color: $0.data.textColorOverride ?? color,
                    fixedFontSize: sharedSize,
                    textData: $0.data)

                if verbose {
                    print(
                        "Rendered title with identifier \"\($0.data.titleIdentifier)\" with font size \(Int(sharedSize))".formattedGreen(),
                        insetByTabs: 1)
                }
            } else {
                let renderedFontsize = try add(
                    title: $0.string,
                    font: $0.data.fontOverride ?? font,
                    color: $0.data.textColorOverride ?? color,
                    maxFontSize: $0.data.maxFontSizeOverride ?? maxFontSize,
                    textData: $0.data)

                if verbose {
                    print(
                        "Rendered title with identifier \"\($0.data.titleIdentifier)\" with font size \(Int(renderedFontsize))".formattedGreen(),
                        insetByTabs: 1)
                }
            }
        }
    }

    public func add(title: String, font: NSFont, color: NSColor, maxFontSize: CGFloat, textData: TextData) throws -> CGFloat {
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

    public func add(title: String, font: NSFont, color: NSColor, fixedFontSize: CGFloat, textData: TextData) throws {
        let adaptedFont = font.toFont(ofSize: fixedFontSize)
        try textRenderer.render(text: title, font: adaptedFont, color: color, alignment: textData.textAlignment, rect: textData.rect, context: context)
    }

    public func add(screenshot: NSBitmapImageRep, with data: ScreenshotData) throws {
        try screenshotRenderer.render(screenshot: screenshot, with: data, in: context)
    }

    // MARK: - Exporting

    public func renderFinalImage() -> CGImage? {
        context.makeImage()
    }

    public func slice(image: CGImage, with size: NSSize) -> [CGImage] {
        guard CGFloat(image.width).truncatingRemainder(dividingBy: size.width) == 0 else {
            print("Image width is not a multiple in width of desired size")
            return []
        }
        let numberOfSlices = image.width / Int(size.width)
        var croppedImages = [CGImage?]()

        for i in 0..<numberOfSlices {
            let rect = CGRect(x: size.width * CGFloat(i), y: 0, width: size.width, height: size.height)
            croppedImages.append(image.cropping(to: rect))
        }
        return croppedImages.compactMap { $0 }
    }

}
