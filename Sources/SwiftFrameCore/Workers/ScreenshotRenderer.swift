import AppKit
import Foundation

final class ScreenshotRenderer {

    // MARK: - Screenshot Rendering

    func render(screenshot: NSBitmapImageRep, with data: ScreenshotData, in context: GraphicsContext) throws {
        let cgImage = try renderScreenshot(screenshot, with: data, in: context)
        let rect = calculateRect(for: data)

        context.cgContext.saveGState()
        context.cgContext.draw(cgImage, in: rect)
        context.cgContext.restoreGState()
    }

    private func renderScreenshot(_ screenshot: NSBitmapImageRep, with data: ScreenshotData, in context: GraphicsContext) throws -> CGImage {
        let ciImage = CIImage(bitmapImageRep: screenshot)

        let perspectiveTransform = CIFilter(name: "CIPerspectiveTransform")!
        perspectiveTransform.setDefaults()
        perspectiveTransform.setValue(data.topLeft.ciVector, forKey: "inputTopLeft")
        perspectiveTransform.setValue(data.topRight.ciVector, forKey: "inputTopRight")
        perspectiveTransform.setValue(data.bottomRight.ciVector, forKey: "inputBottomRight")
        perspectiveTransform.setValue(data.bottomLeft.ciVector, forKey: "inputBottomLeft")
        perspectiveTransform.setValue(ciImage, forKey: kCIInputImageKey)

        guard
            let compositeImage = perspectiveTransform.outputImage,
            let cgImage = context.ciContext.createCGImage(compositeImage, from: calculateRect(for: data))
        else {
            throw NSError(description: "Could not skew screenshot")
        }
        return cgImage
    }

    private func calculateRect(for screenshotData: ScreenshotData) -> NSRect {
        let xCoordinates = [
            screenshotData.bottomLeft.x,
            screenshotData.bottomRight.x,
            screenshotData.topLeft.x,
            screenshotData.topRight.x
        ]

        let yCoordinates = [
            screenshotData.bottomLeft.y,
            screenshotData.bottomRight.y,
            screenshotData.topLeft.y,
            screenshotData.topRight.y
        ]

        // Can force-unwrap since the are never empty
        let minX = xCoordinates.min()!
        let maxX = xCoordinates.max()!
        let minY = yCoordinates.min()!
        let maxY = yCoordinates.max()!

        return NSRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

}
