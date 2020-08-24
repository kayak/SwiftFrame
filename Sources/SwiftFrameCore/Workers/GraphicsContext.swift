import AppKit
import CoreGraphics
import Foundation

class GraphicsContext {

    let cg: CGContext
    private let colorSpace: CGColorSpace

    lazy var ci: CIContext = {
        CIContext(cgContext: cg, options: [
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
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        guard let cgContext = context else {
            throw NSError(description: "Failed to create graphics context")
        }
        self.cg = cgContext
        self.colorSpace = colorSpace
    }

}
