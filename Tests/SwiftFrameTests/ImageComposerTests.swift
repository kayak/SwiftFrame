import Foundation
import XCTest
@testable import SwiftFrameCore

class ImageComposerTests: XCTestCase {

    let goodTextData: [String : Any] = [
        "titleIdentifier": "someID",
        "textAlignment": NSTextAlignment.center,
        "topLeft": Point(x: 10, y: 20),
        "bottomRight": Point(x: 15, y: 5)
    ]

    func testRenderTemplateFile() throws {
        let templateFile = makeImageRepresentationWithSize(CGSize(width: 100, height: 50))
        let composer = try ImageComposer(templateFile)
        try composer.addTemplateImage()
        XCTAssertNotNil(composer.renderFinalImage())
    }

    func testTemplateImageSlicesCorrectly() throws {
        let templateFile = makeImageRepresentationWithSize(CGSize(width: 100, height: 50))
        let composer = try ImageComposer(templateFile)
        try composer.addTemplateImage()

        guard let image = composer.renderFinalImage() else {
            throw NSError(description: "Rendered image was nil")
        }

        let slices = composer.slice(image: image, with: NSSize(width: 20, height: 50))
        XCTAssertEqual(slices.count, 5)
    }

    func testTemplateImagesNotCorrectSize() throws {
        let templateFile = makeImageRepresentationWithSize(CGSize(width: 100, height: 50))
        let composer = try ImageComposer(templateFile)
        try composer.addTemplateImage()

        guard let image = composer.renderFinalImage() else {
            throw NSError(description: "Rendered image was nil")
        }

        let slices = composer.slice(image: image, with: NSSize(width: 30, height: 50))
        XCTAssert(slices.isEmpty)
    }

    func testCanRenderInContext() throws {
        let textData = try TextData(from: goodTextData)

        let size = CGSize(width: 100, height: 200)
        let composer = try ImageComposer(makeImageRepresentationWithSize(size))
        XCTAssertNoThrow(try composer.add(
            title: "Some testing title",
            font: .systemFont(ofSize: 20),
            color: .red,
            fixedFontSize: 30,
            textData: textData))
    }

    func testRenderDynamicTextSize() throws {
        let textData = try TextData(from: goodTextData)

        let size = CGSize(width: 100, height: 200)
        let composer = try ImageComposer(makeImageRepresentationWithSize(size))
        XCTAssertNoThrow(try composer.add(
            title: "Some very long but interesting title",
            font: .systemFont(ofSize: 20),
            color: .red,
            maxFontSize: 4,
            textData: textData))
    }

}

func makeImageRepresentationWithSize(_ size: CGSize) -> NSBitmapImageRep {
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
