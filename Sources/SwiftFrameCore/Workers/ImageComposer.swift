import AppKit
import Foundation
import CoreGraphics
import CoreImage

final class ImageComposer {

    // MARK: - Nested Type

    enum FontMode {
        case dynamic(maxSize: CGFloat)
        case fixed(pointSize: CGFloat)
    }

    // MARK: - Properties

    private let textRenderer = TextRenderer()
    private let screenshotRenderer = ScreenshotRenderer()

    let context: GraphicsContext

    // MARK: - Init

    init(canvasSize: CGSize) throws {
        self.context = try GraphicsContext(size: canvasSize)
    }

    // MARK: - Composition

    func addTemplateImage(_ image: NSBitmapImageRep) throws {
        guard let templateImage = image.cgImage else {
            throw NSError(description: "Could not render template image")
        }

        context.cg.saveGState()
        context.cg.draw(templateImage, in: image.ky_nativeRect)
        context.cg.restoreGState()
    }

    // MARK: - Titles Rendering

    func addStrings(_ associatedStrings: [AssociatedString], maxFontSizeByGroup: [String: CGFloat], font: NSFont, color: NSColor, maxFontSize: CGFloat) throws {
        try associatedStrings.forEach {
            let fontMode: FontMode
            if let sharedSize = $0.data.groupIdentifier.flatMap({ maxFontSizeByGroup[$0] }) {
                // Can use fixed font size since common maximum has already been calculated
                fontMode = .fixed(pointSize: sharedSize)
            } else {
                fontMode = .dynamic(maxSize: $0.data.maxFontSizeOverride ?? maxFontSize)
            }

            try add(
                title: $0.string,
                font: $0.data.fontOverride?.font() ?? font,
                color: $0.data.textColorOverride ?? color,
                fontMode: fontMode,
                textData: $0.data)
        }
    }

    private func add(title: String, font: NSFont, color: NSColor, fontMode: FontMode, textData: TextData) throws {
        let fontSize: CGFloat
        switch fontMode {
        case let .dynamic(maxSize: maxSize):
            fontSize = try textRenderer.maximumFontSizeThatFits(
                string: title,
                font: font,
                alignment: textData.textAlignment,
                maxSize: maxSize,
                size: textData.rect.size)
        case let .fixed(pointSize: size):
            fontSize = size
        }
        let adaptedFont = font.ky_toFont(ofSize: fontSize)
        try textRenderer.render(text: title, font: adaptedFont, color: color, alignment: textData.textAlignment, rect: textData.rect, context: context)
    }

    // MARK: - Screenshots Rendering

    func add(screenshots: [String: URL], with screenshotData: [ScreenshotData], for locale: String) throws {
        try screenshotData.forEach { data in
            guard let image = NSBitmapImageRep.ky_loadFromURL(screenshots[data.screenshotName]) else {
                throw NSError(description: "Screenshot named \(data.screenshotName) not found in folder \"\(locale)\"")
            }
            try screenshotRenderer.render(screenshot: image, with: data, in: context)
        }
    }

}
