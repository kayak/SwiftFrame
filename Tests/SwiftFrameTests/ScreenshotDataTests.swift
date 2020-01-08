import Foundation
import XCTest
@testable import SwiftFrame

class ScreenshotDataTests: XCTestCase {

    func testScreenshotsMatchingTemplateFile() {

    }

}

private func makeImageRepresentationWithSize(_ size: CGSize) -> NSImageRep {
    let context = CGContext(
        data: nil,
        width: Int(size.width),
        height: Int(size.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.setFillColor(.white)
    context.fill(NSRect(x: 0, y: 0, width: size.width, height: size.height))
    return NSBitmapImageRep(cgImage: context.makeImage()!)
}
