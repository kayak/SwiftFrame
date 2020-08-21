import AppKit
import CoreGraphics
import Foundation

class GraphicsContext {

    let cgContext: CGContext
    private let colorSpace: CGColorSpace

    lazy var ciContext: CIContext = {
        CIContext(cgContext: cgContext, options: [
            CIContextOption.workingColorSpace: colorSpace,
            CIContextOption.useSoftwareRenderer: false
        ])
    }()


    init(canvasSize: CGSize) throws {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: Int(canvasSize.width),
            height: Int(canvasSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        guard let cgContext = context else {
            throw NSError(description: "Failed to create graphics context")
        }
        self.cgContext = cgContext
        self.colorSpace = colorSpace
    }

}
