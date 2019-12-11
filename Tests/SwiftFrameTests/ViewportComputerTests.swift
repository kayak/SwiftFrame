import Foundation
import XCTest
@testable import SwiftFrame

class ViewportComputerTests: XCTestCase {

    func testComputesViewportForUniformFrameImage() {
        let frame = makeFrameImage(size: CGSize(width: 100, height: 100), viewportXInset: 0, viewportYInset: 0)
        let viewport = ViewportComputer().computeViewportRect(from: frame, hasNotch: false)
        XCTAssertEqual(viewport, NSRect(x: 0, y: 0, width: 100, height: 100))
    }

    func testComputesViewportForFrameImageWithXInset() {
        let frame = makeFrameImage(size: CGSize(width: 100, height: 100), viewportXInset: 2, viewportYInset: 0)
        let viewport = ViewportComputer().computeViewportRect(from: frame, hasNotch: false)
        XCTAssertEqual(viewport, NSRect(x: 2, y: 0, width: 96, height: 100))
    }

    func testComputesViewportForFrameImageWithYInset() {
        let frame = makeFrameImage(size: CGSize(width: 100, height: 100), viewportXInset: 0, viewportYInset: 2)
        let viewport = ViewportComputer().computeViewportRect(from: frame, hasNotch: false)
        XCTAssertEqual(viewport, NSRect(x: 0, y: 2, width: 100, height: 96))
    }

    func testComputesViewportForFrameImageWithXAndYInset() {
        let frame = makeFrameImage(size: CGSize(width: 100, height: 100), viewportXInset: 2, viewportYInset: 2)
        let viewport = ViewportComputer().computeViewportRect(from: frame, hasNotch: false)
        XCTAssertEqual(viewport, NSRect(x: 2, y: 2, width: 96, height: 96))
    }

    func testComputesViewportFor6SFrameAsset() {
        let frame = NSImage(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "iPhone6s", ofType: "png")!)!
        let viewport = ViewportComputer().computeViewportRect(from: frame, hasNotch: false)
        XCTAssertEqual(viewport, NSRect(x: 63, y: 183, width: 750, height: 1334))
    }

    func testComputesViewportForAsymmetric8PlusFrameAsset() {
        let frame = NSImage(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "iPhone8Plus", ofType: "png")!)!
        let viewport = ViewportComputer().computeViewportRect(from: frame, hasNotch: false)
        XCTAssertEqual(viewport, NSRect(x: 63, y: 83, width: 1305 - 63, height: 2291 - 83))
    }

    func testDoesNotComputeViewportForXFrameAssetWithoutNotchFlag() {
        let frame = NSImage(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "iPhoneX", ofType: "png")!)!
        let viewport = ViewportComputer().computeViewportRect(from: frame, hasNotch: false)
        XCTAssertNotEqual(viewport, NSRect(x: 65, y: 65, width: 1125, height: 2436))
    }

    func testComputesViewportForXFrameAsset() {
        let frame = NSImage(contentsOfFile: Bundle(for: self.classForCoder).path(forResource: "iPhoneX", ofType: "png")!)!
        let viewport = ViewportComputer().computeViewportRect(from: frame, hasNotch: true)
        XCTAssertEqual(viewport, NSRect(x: 65, y: 65, width: 1125, height: 2436))
    }

}

private func makeFrameImage(size: CGSize, viewportXInset: Int, viewportYInset: Int) -> NSImage {
    let context = CGContext(
        data: nil,
        width: Int(size.width),
        height: Int(size.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.setFillColor(.black)
    context.fill(NSRect(x: 0, y: 0, width: size.width, height: size.height))
    context.setFillColor(.white)
    context.fill(NSRect(x: 0, y: 0, width: size.width, height: size.height).insetBy(dx: CGFloat(viewportXInset), dy: CGFloat(viewportYInset)))
    return NSImage(cgImage: context.makeImage()!, size: size)
}
