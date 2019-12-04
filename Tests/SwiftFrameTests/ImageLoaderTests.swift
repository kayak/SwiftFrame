import Foundation
import XCTest
@testable import SwiftFrameCore

class ImageLoaderTests: XCTestCase {

    func testDoesNotFindRepresentationInEmptyArray() {
        let loader = ImageLoader()
        let representation = loader.representation(from: [], forSize: CGSize(width: 100, height: 100), allowDownSampling: true)
        XCTAssertNil(representation)
    }

    func testFindsExactlyMatchingRepresentation() {
        let loader = ImageLoader()
        let representations = [
            makeImageRepresentationWithSize(CGSize(width: 100, height: 100)),
            makeImageRepresentationWithSize(CGSize(width: 200, height: 200)),
            makeImageRepresentationWithSize(CGSize(width: 300, height: 300))]
        let representation = loader.representation(
            from: representations,
            forSize: CGSize(width: 200, height: 200),
            allowDownSampling: false)
        XCTAssertEqual(representation, representations[1])
    }

    func testDoesNotFindExactlyMatchingRepresentation() {
        let loader = ImageLoader()
        let representations = [
            makeImageRepresentationWithSize(CGSize(width: 100, height: 100)),
            makeImageRepresentationWithSize(CGSize(width: 200, height: 200)),
            makeImageRepresentationWithSize(CGSize(width: 300, height: 300))]
        let representation = loader.representation(
            from: representations,
            forSize: CGSize(width: 250, height: 250),
            allowDownSampling: false)
        XCTAssertNil(representation)
    }

    func testFindsScalableRepresentation() {
        let loader = ImageLoader()
        let representations = [
            makeImageRepresentationWithSize(CGSize(width: 100, height: 100)),
            makeImageRepresentationWithSize(CGSize(width: 200, height: 200)),
            makeImageRepresentationWithSize(CGSize(width: 300, height: 300))]
        let representation = loader.representation(
            from: representations,
            forSize: CGSize(width: 250, height: 250),
            allowDownSampling: true)
        XCTAssertEqual(representation, representations[2])
    }

    func testDoesNotFindScalableRepresentation() {
        let loader = ImageLoader()
        let representations = [
            makeImageRepresentationWithSize(CGSize(width: 100, height: 100)),
            makeImageRepresentationWithSize(CGSize(width: 200, height: 200)),
            makeImageRepresentationWithSize(CGSize(width: 300, height: 300))]
        let representation = loader.representation(
            from: representations,
            forSize: CGSize(width: 350, height: 350),
            allowDownSampling: true)
        XCTAssertNil(representation)
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
