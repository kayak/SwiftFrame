import AppKit
import Foundation
import CoreGraphics
import CoreImage

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
        try textData.forEach {
            try textRenderer.renderText(
                forKey: $0.titleIdentifier,
                locale: locale,
                deviceIdentifier: deviceIdentifier,
                alignment: $0.textAlignment,
                rect: $0.rect,
                context: context
            )
        }
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
