import AppKit
import Foundation
import CoreGraphics
import CoreImage

private let kNumTitleLines = 2
private let kMaxTitleFontSize = CGFloat(80)

final class ImageComposer {

    private let textRenderer = TextRenderer()
    private let templateImage: NSBitmapImageRep
    private let context: CGContext

    init(_ templateImage: NSBitmapImageRep) throws {
        self.templateImage = templateImage
        self.context = try ImageComposer.createContext(size: templateImage.nativeSize)

        //context.draw(self.templateImage, in: rect)
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

    /// Adapts the specified font to fit all of the supplied titles at the same size taking padding and canvas width into account
    func adapt(titleFont: NSFont, toFitTitleTexts titleTexts: [String], titlePadding: NSEdgeInsets, width: CGFloat) throws -> NSFont {
        let size = try textRenderer.maximumFontSizeThatFits(
            texts: titleTexts,
            font: titleFont,
            lines: kNumTitleLines,
            width: width - titlePadding.left - titlePadding.right,
            upperBound: kMaxTitleFontSize)
        return titleFont.toFont(ofSize: size)
    }

    // MARK: - Composition

//    func compose(
//        //background: Background,
//        frame: NSImage,
//        framePadding: Int,
//        viewport: NSRect,
//        viewportMask: NSImage?,
//        screenshot: NSImage,
//        titleText: String,
//        titleFont: NSFont,
//        titleColor: NSColor,
//        titlePadding: NSEdgeInsets) throws -> CGImage
//    {
//        let context = try createContext(size: screenshot.size)
//
//        //addBackground(background, context: context)
//
//        let titleRect = try add(title: titleText, font: titleFont, color: titleColor, padding: titlePadding, context: context)
//
//        let frameScale = CGFloat(context.width - 2 * framePadding) / frame.size.width
//        let frameYOffset = CGFloat(context.height) / frameScale - frame.size.height - (titlePadding.top + titleRect.height + titlePadding.bottom) / frameScale
//
//        add(frame: frame, scale: frameScale, yOffset: frameYOffset, context: context)
//        add(screenshot: screenshot, frame: frame, viewport: viewport, viewportMask: viewportMask, scale: frameScale, yOffset: frameYOffset, context: context)
//
//        guard let image = context.makeImage() else {
//            throw NSError(description: "Failed to retrieve image from graphics context")
//        }
//        return image
//    }

    // Returns the rect used for rendering the title
//    private func add(title: String, font: NSFont, color: NSColor, padding: NSEdgeInsets, context: CGContext) throws -> NSRect {
//        let width = try textRenderer.minimumWidthThatFits(
//            text: title,
//            font: font,
//            lines: kNumTitleLines,
//            upperBound: CGFloat(context.width) - padding.left - padding.right)
//        let height = textRenderer.suggestHeightForRendering(text: title, font: font, width: width)
//        let rect = CGRect(x: (CGFloat(context.width) - width) / 2, y: CGFloat(context.height) - padding.top - height, width: width, height: height)
//        textRenderer.render(text: title, font: font, color: color, alignment: .center, rect: rect, context: context)
//        return rect
//    }

    func addTemplateImage() throws {
        guard let templateImage = templateImage.cgImage else {
            throw NSError(description: "Could not render template image")
        }

        context.saveGState()
        defer { context.restoreGState() }

        context.draw(templateImage, in: self.templateImage.nativeRect)
    }

    func add(screenshot: NSBitmapImageRep, with data: ScreenshotData) throws {
        let cgImage = try renderScreenshot(screenshot, with: data)
        let rect = calculateRect(for: data)

        context.saveGState()
        defer { context.restoreGState() }

        context.draw(cgImage, in: rect)
    }

    private func renderScreenshot(_ screenshot: NSBitmapImageRep, with data: ScreenshotData) throws -> CGImage {
        let ciImage = CIImage(bitmapImageRep: screenshot)

        let perspectiveTransform = CIFilter(name: "CIPerspectiveTransform")!
        perspectiveTransform.setValue(data.topLeft!.ciVector, forKey: "inputTopLeft")
        perspectiveTransform.setValue(data.topRight!.ciVector, forKey: "inputTopRight")
        perspectiveTransform.setValue(data.bottomRight.ciVector, forKey: "inputBottomRight")
        perspectiveTransform.setValue(data.bottomLeft.ciVector, forKey: "inputBottomLeft")
        perspectiveTransform.setValue(ciImage, forKey: kCIInputImageKey)

        guard
            let compositeImage = perspectiveTransform.outputImage,
            let cgImage = CIContext().createCGImage(compositeImage, from: calculateRect(for: data))
        else {
            throw NSError(description: "Could not skew screenshot")
        }
        return cgImage
    }

    func calculateRect(for screenshotData: ScreenshotData) -> NSRect {
        let xCoordinates = [
            screenshotData.bottomLeft.x,
            screenshotData.bottomRight.x,
            screenshotData.topLeft?.x,
            screenshotData.topRight?.x
        ].compactMap { $0 }

        let yCoordinates = [
            screenshotData.bottomLeft.y,
            screenshotData.bottomRight.y,
            screenshotData.topLeft?.y,
            screenshotData.topRight?.y
        ].compactMap { $0 }

        // Temp
        let minX = xCoordinates.min()!
        let maxX = xCoordinates.max()!
        let minY = yCoordinates.min()!
        let maxY = yCoordinates.max()!

        return NSRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
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
