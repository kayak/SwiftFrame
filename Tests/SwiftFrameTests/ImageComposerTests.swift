import Foundation
import XCTest
@testable import SwiftFrameCore

class ImageComposerTests: XCTestCase {

    func testRenderTemplateFile() throws {
        let size = CGSize(width: 100, height: 50)
        let templateFile = makeImageRepresentationWithSize(size)
        let composer = try ImageComposer(canvasSize: size)
        try composer.addTemplateImage(templateFile)
        XCTAssertNotNil(composer.renderFinalImage())
    }

    func testTemplateImageSlicesCorrectly() throws {
        let size = CGSize(width: 100, height: 50)
        let templateFile = makeImageRepresentationWithSize(size)
        let composer = try ImageComposer(canvasSize: size)
        try composer.addTemplateImage(templateFile)

        guard let image = composer.renderFinalImage() else {
            throw NSError(description: "Rendered image was nil")
        }

        let slices = composer.slice(image: image, with: NSSize(width: 20, height: 50))
        XCTAssertEqual(slices.count, 5)
    }

    func testTemplateImagesNotCorrectSize() throws {
        let size = CGSize(width: 100, height: 50)
        let templateFile = makeImageRepresentationWithSize(size)
        let composer = try ImageComposer(canvasSize: size)
        try composer.addTemplateImage(templateFile)

        guard let image = composer.renderFinalImage() else {
            throw NSError(description: "Rendered image was nil")
        }

        let slices = composer.slice(image: image, with: NSSize(width: 30, height: 50))
        XCTAssert(slices.isEmpty)
    }

    func testCanRenderInContext() throws {
        let textData = TextData.goodData

        let size = CGSize(width: 100, height: 200)
        let composer = try ImageComposer(canvasSize: size)
        XCTAssertNoThrow(try composer.add(
            title: "Some testing title",
            font: .systemFont(ofSize: 20),
            color: .red,
            fixedFontSize: 30,
            textData: textData))
    }

    func testRenderDynamicTextSize() throws {
        let textData = TextData.invertedData

        let size = CGSize(width: 100, height: 200)
        let composer = try ImageComposer(canvasSize: size)
        XCTAssertNoThrow(try composer.add(
            title: "Some very long but interesting title",
            font: .systemFont(ofSize: 20),
            color: .red,
            maxFontSize: 4,
            textData: textData))
    }

}

func makeCGContext(_ size: CGSize) -> CGContext {
    CGContext(
        data: nil,
        width: Int(size.width),
        height: Int(size.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
}

func makeImageRepresentationWithSize(_ size: CGSize) -> NSBitmapImageRep {
    let context = makeCGContext(size)
    context.setFillColor(.white)
    context.fill(NSRect(x: 0, y: 0, width: size.width, height: size.height))
    return NSBitmapImageRep(cgImage: context.makeImage()!)
}
