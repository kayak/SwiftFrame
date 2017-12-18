import AppKit
import Foundation

private let kNumTitleLines = 2
private let kMaxTitleFontSize = CGFloat(80)

final class ImageComposer {

    private let textRenderer = TextRenderer()

    // MARK: - Preparation

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

    func compose(
        background: Background,
        frame: NSImage,
        framePadding: Int,
        viewport: NSRect,
        screenshot: NSImage,
        titleText: String,
        titleFont: NSFont,
        titleColor: NSColor,
        titlePadding: NSEdgeInsets) throws -> CGImage
    {
        let context = try createContext(size: screenshot.size)

        addBackground(background, context: context)

        let titleRect = try add(title: titleText, font: titleFont, color: titleColor, padding: titlePadding, context: context)

        let frameScale = CGFloat(context.width - 2 * framePadding) / frame.size.width
        let frameYOffset = CGFloat(context.height) / frameScale - frame.size.height - (titlePadding.top + titleRect.height + titlePadding.bottom) / frameScale
        add(frame: frame, scale: frameScale, yOffset: frameYOffset, context: context)
        add(screenshot: screenshot, viewport: viewport, scale: frameScale, yOffset: frameYOffset, context: context)

        guard let image = context.makeImage() else {
            throw NSError(description: "Failed to retrieve image from graphics context")
        }
        return image
    }

    private func createContext(size: CGSize) throws -> CGContext {
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

    private func addBackground(_ background: Background, context: CGContext) {
        switch background {
        case .solid(let color):
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: context.width, height: context.height))
        case .linearGradient(let direction, let colors):
            var locations = [CGFloat]()
            locations.append(CGFloat(0))
            locations.append(contentsOf: (1..<colors.count-1).map({ CGFloat($0) / CGFloat(colors.count - 1) }))
            locations.append(CGFloat(1))
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map({ $0.cgColor }) as CFArray,
                locations: locations)
            context.drawLinearGradient(
                gradient!,
                start: CGPoint(x: direction.relativeStartX * CGFloat(context.width), y: direction.relativeStartY * CGFloat(context.height)),
                end: CGPoint(x: direction.relativeEndX * CGFloat(context.width), y: direction.relativeEndY * CGFloat(context.height)),
                options: CGGradientDrawingOptions(rawValue: 0))
        }
    }

    // Returns the rect used for rendering the title
    private func add(title: String, font: NSFont, color: NSColor, padding: NSEdgeInsets, context: CGContext) throws -> NSRect {
        let width = try textRenderer.minimumWidthThatFits(
            text: title,
            font: font,
            lines: kNumTitleLines,
            upperBound: CGFloat(context.width) - padding.left - padding.right)
        let height = textRenderer.suggestHeightForRendering(text: title, font: font, width: width)
        let rect = CGRect(x: (CGFloat(context.width) - width) / 2, y: CGFloat(context.height) - padding.top - height, width: width, height: height)
        textRenderer.render(text: title, font: font, color: color, alignment: .center, rect: rect, context: context)
        return rect
    }

    private func add(frame: NSImage, scale: CGFloat, yOffset: CGFloat, context: CGContext) {
        context.saveGState()
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: (CGFloat(context.width) / scale - frame.size.width) / 2.0, y: yOffset)
        var rect = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        context.draw(frame.cgImage(forProposedRect: &rect, context: nil, hints: nil)!, in: rect)
        context.restoreGState()
    }

    private func add(screenshot: NSImage, viewport: NSRect, scale: CGFloat, yOffset: CGFloat, context: CGContext) {
        context.saveGState()
        context.scaleBy(x: scale, y: scale)
        context.translateBy(x: (CGFloat(context.width) / scale - viewport.size.width) / 2.0 - viewport.origin.x, y: yOffset)
        var rect = viewport
        context.draw(screenshot.cgImage(forProposedRect: &rect, context: nil, hints: nil)!, in: rect)
        context.restoreGState()
    }

}
