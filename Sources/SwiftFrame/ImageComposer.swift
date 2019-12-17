import AppKit
import Foundation
import CoreGraphics
import CoreImage

private let kNumTitleLines = 2
private let kMaxTitleFontSize = CGFloat(80)

final class ImageComposer {

    private let textRenderer = TextRenderer()
    private let templateImage: CGImage
    private let imageSize: NSRect
    private let context: CGContext

    init(_ templateImage: NSImage) throws {
        var rect = NSRect(origin: .zero, size: templateImage.size)
        guard let image = templateImage.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
            throw NSError(description: "Could not create CGImage from template file")
        }
        self.templateImage = image
        self.imageSize = rect
        self.context = try ImageComposer.createContext(size: templateImage.size)

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

//    private func addBackground(_ background: Background, context: CGContext) {
//        switch background {
//        case .solid(let color):
//            context.setFillColor(color.cgColor)
//            context.fill(CGRect(x: 0, y: 0, width: context.width, height: context.height))
//        case .linearGradient(let direction, let colors):
//            var locations = [CGFloat]()
//            locations.append(CGFloat(0))
//            locations.append(contentsOf: (1..<colors.count-1).map({ CGFloat($0) / CGFloat(colors.count - 1) }))
//            locations.append(CGFloat(1))
//            let gradient = CGGradient(
//                colorsSpace: CGColorSpaceCreateDeviceRGB(),
//                colors: colors.map({ $0.cgColor }) as CFArray,
//                locations: locations)
//            context.drawLinearGradient(
//                gradient!,
//                start: CGPoint(x: direction.relativeStartX * CGFloat(context.width), y: direction.relativeStartY * CGFloat(context.height)),
//                end: CGPoint(x: direction.relativeEndX * CGFloat(context.width), y: direction.relativeEndY * CGFloat(context.height)),
//                options: CGGradientDrawingOptions(rawValue: 0))
//        }
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
//
//    private func add(frame: NSImage, scale: CGFloat, yOffset: CGFloat, context: CGContext) {
//        context.saveGState()
//        context.scaleBy(x: scale, y: scale)
//        context.translateBy(x: (CGFloat(context.width) / scale - frame.size.width) / 2.0, y: yOffset)
//        var rect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
//        context.draw(frame.cgImage(forProposedRect: &rect, context: nil, hints: nil)!, in: rect)
//        context.restoreGState()
//    }
//
//    private func add(screenshot: NSImage, frame: NSImage, viewport: NSRect, viewportMask: NSImage?, scale: CGFloat, yOffset: CGFloat, context: CGContext) {
//        context.saveGState()
//        context.scaleBy(x: scale, y: scale)
//        context.translateBy(x: (CGFloat(context.width) / scale - viewport.size.width) / 2.0 - viewport.origin.x, y: yOffset)
//        var rect = viewport
//        if let mask = viewportMask?.cgImage(forProposedRect: &rect, context: nil, hints: nil) {
//            context.clip(to: viewport, mask: mask)
//        }
//        context.draw(screenshot.cgImage(forProposedRect: &rect, context: nil, hints: nil)!, in: rect)
//        context.restoreGState()
//    }

    func add(screenshot: NSImage, with data: ScreenshotData) throws {
        let cgImage = try renderScreenshot(screenshot, with: data)

        context.saveGState()
        defer { context.restoreGState() }

        context.draw(cgImage, in: imageSize)
    }

    private func renderScreenshot(_ screenshot: NSImage, with data: ScreenshotData) throws -> CGImage {
        guard let ciImage = screenshot.ciImage else {
            throw NSError(description: "Could not convert screenshot into required format")
        }

        let background = CIImage(cgImage: templateImage)
        let composite = CIFilter(name: "CISourceAtopCompositing")!
        let perspectiveTransform = CIFilter(name: "CIPerspectiveTransform")!

        perspectiveTransform.setValue(CIVector(cgPoint: data.topLeft!.cgPoint),
                                      forKey: "inputTopLeft")
        perspectiveTransform.setValue(CIVector(cgPoint: data.topRight!.cgPoint),
                                      forKey: "inputTopRight")
        perspectiveTransform.setValue(CIVector(cgPoint: data.bottomRight.cgPoint),
                                      forKey: "inputBottomRight")
        perspectiveTransform.setValue(CIVector(cgPoint: data.bottomLeft.cgPoint),
                                      forKey: "inputBottomLeft")
        perspectiveTransform.setValue(ciImage,
                                      forKey: kCIInputImageKey)

        composite.setValue(background,
                           forKey: kCIInputBackgroundImageKey)
        composite.setValue(perspectiveTransform.outputImage!,
                           forKey: kCIInputImageKey)

        guard
            let compositeImage = composite.outputImage,
            let cgImage = CIContext().createCGImage(compositeImage, from: imageSize)
        else {
            throw NSError(description: "Could not skew screenshot")
        }
        return cgImage
    }

    // MARK: - Exporting

    func renderFinalImage() -> CGImage? {
        //context.draw(templateImage, in: imageSize)
        return context.makeImage()
    }

}

extension NSImage {
    public var ciImage: CIImage? {
        guard let imageData = self.tiffRepresentation else { return nil }
        return CIImage(data: imageData)
    }
}
