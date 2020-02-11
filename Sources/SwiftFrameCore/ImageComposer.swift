import AppKit
import Foundation
import CoreGraphics
import CoreImage

public final class ImageComposer {

    // MARK: - Properties

    public let textRenderer = TextRenderer()
    private let screenshotRenderer = ScreenshotRenderer()
    private let imageWriter = ImageWriter()
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

    public func add(screenshots: [String: NSBitmapImageRep], with screenshotData: [ScreenshotData], for locale: String) throws {
        try screenshotData.forEach { data in
            guard let image = screenshots[data.screenshotName] else {
                throw NSError(description: "Screenshot named \(data.screenshotName) not found in folder \"\(locale)\"")
            }
            try add(screenshot: image, with: data)

            if verbose {
                print("Rendered screenshot \(data.screenshotName)".formattedGreen(), insetByTabs: 1)
            }
        }
    }

    public func add(screenshot: NSBitmapImageRep, with data: ScreenshotData) throws {
        try screenshotRenderer.render(screenshot: screenshot, with: data, in: context)
    }

    // MARK: - Exporting

    public func finish(with outputPaths: [LocalURL], sliceSize: CGSize, outputWholeImage: Bool, locale: String, suffix: String) throws {
        guard let finalImage = renderFinalImage() else {
            throw NSError(description: "Could not render output image")
        }
        let slices = sliceImage(finalImage, with: sliceSize)
        try write(images: slices, to: outputPaths, locale: locale, suffix: suffix)

        if outputWholeImage {
            try outputPaths.forEach { try imageWriter.write(finalImage, to: $0.absoluteURL, fileName: "\(locale)-\(suffix)-big.png") }
        }
    }

    public func renderFinalImage() -> CGImage? {
        context.makeImage()
    }

    public func sliceImage(_ image: CGImage, with size: CGSize) -> [CGImage] {
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

    public func write(images: [CGImage], to outputPaths: [LocalURL], locale: String, suffix: String) throws {
        try outputPaths.forEach { url in
            try images.enumerated().forEach { tuple in
                try imageWriter.write(tuple.element, to: url.absoluteString, locale: locale, deviceID: suffix, index: tuple.offset)
            }
        }
    }

}
