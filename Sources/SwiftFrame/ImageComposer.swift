import AppKit
import Foundation
import CoreGraphics
import CoreImage

final class ImageComposer {

    public let textRenderer = TextRenderer()
    private let screenshotRenderer = ScreenshotRenderer()
    private let templateImage: NSBitmapImageRep
    private let context: CGContext

    init(_ templateImage: NSBitmapImageRep) throws {
        self.templateImage = templateImage
        self.context = try ImageComposer.createContext(size: templateImage.nativeSize)
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

    func addTemplateImage() throws {
        guard let templateImage = templateImage.cgImage else {
            throw NSError(description: "Could not render template image")
        }

        context.saveGState()
        defer { context.restoreGState() }

        context.draw(templateImage, in: self.templateImage.nativeRect)
    }

    func add(title: String, font: NSFont, color: NSColor, maxFontSize: CGFloat, textData: TextData) throws -> CGFloat {
        let fontSize = try textRenderer.maximumFontSizeThatFits(string: title, size: textData.rect.size, font: font, maxFontSize: maxFontSize)
        let adaptedFont = font.toFont(ofSize: fontSize)
        try textRenderer.render(text: title, font: adaptedFont, color: color, alignment: textData.textAlignment, rect: textData.rect, context: context)
        return fontSize
    }

    func add(title: String, font: NSFont, color: NSColor, fixedFontSize: CGFloat, textData: TextData) throws {
        let adaptedFont = font.toFont(ofSize: fixedFontSize)
        try textRenderer.render(text: title, font: adaptedFont, color: color, alignment: textData.textAlignment, rect: textData.rect, context: context)
    }

    func add(screenshot: NSBitmapImageRep, with data: ScreenshotData) throws {
        try screenshotRenderer.render(screenshot: screenshot, with: data, in: context)
    }

    // MARK: - Exporting

    func renderFinalImage() -> CGImage? {
        context.makeImage()
    }

    func slice(image: CGImage, with size: NSSize) -> [CGImage] {
        guard size.width.truncatingRemainder(dividingBy: CGFloat(size.width)) == 0 else {
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

extension NSBitmapImageRep {
    /// When dealing with screenshots from an iOS device for example, the size returned by the `size` property
    /// is scaled down by the UIKit scale of the device. You can use this property to get the actual pixel size
    var nativeSize: NSSize {
        NSSize(width: pixelsWide, height: pixelsHigh)
    }

    var nativeRect: NSRect {
        NSRect(origin: .zero, size: nativeSize)
    }
}
