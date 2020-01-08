import AppKit
import Foundation

final class ScreenshotRenderer {

    public func render(screenshot: NSBitmapImageRep, with data: ScreenshotData, in context: CGContext) throws {
        let cgImage = try renderScreenshot(screenshot, with: data)
        let rect = calculateRect(for: data)

        context.saveGState()
        defer { context.restoreGState() }

        context.draw(cgImage, in: rect)
    }

    private func renderScreenshot(_ screenshot: NSBitmapImageRep, with data: ScreenshotData) throws -> CGImage {
        let ciImage = CIImage(bitmapImageRep: screenshot)

        let perspectiveTransform = CIFilter(name: "CIPerspectiveTransform")!
        perspectiveTransform.setValue(data.topLeft.ciVector, forKey: "inputTopLeft")
        perspectiveTransform.setValue(data.topRight.ciVector, forKey: "inputTopRight")
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

        // Can force-unwrap since we sequence is guaranteed to be non-empty
        let minX = xCoordinates.min()!
        let maxX = xCoordinates.max()!
        let minY = yCoordinates.min()!
        let maxY = yCoordinates.max()!

        return NSRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

}
