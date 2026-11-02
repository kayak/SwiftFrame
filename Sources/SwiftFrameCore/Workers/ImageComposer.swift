import AppKit
import CoreGraphics
import CoreImage
import Foundation

final class ImageComposer {

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

    func addStrings(_ textData: [TextData], locale: String, deviceIdentifier: String) throws {
        for text in textData {
            try textRenderer.renderText(
                forKey: text.titleIdentifier,
                locale: locale,
                deviceIdentifier: deviceIdentifier,
                alignment: text.textAlignment,
                rect: text.rect,
                context: context
            )
        }
    }

    // MARK: - Screenshots Rendering

    func add(screenshots: [String: URL], with screenshotData: [ScreenshotData], for locale: String) throws {
        for data in screenshotData {
            guard let image = NSBitmapImageRep.ky_loadFromURL(screenshots[data.screenshotName]) else {
                throw NSError(description: "Screenshot named \(data.screenshotName) not found in folder \"\(locale)\"")
            }
            try screenshotRenderer.render(screenshot: image, with: data, in: context)
        }
    }

}
