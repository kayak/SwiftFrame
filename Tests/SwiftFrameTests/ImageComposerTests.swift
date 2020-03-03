import Foundation
import XCTest
@testable import SwiftFrameCore

class ImageComposerTests: XCTestCase {

    func testRenderTemplateFile() throws {
        let size = CGSize(width: 100, height: 50)
        let templateFile = CGContext.makeImageRepWithSize(size)
        let composer = try ImageComposer(canvasSize: size)
        try composer.addTemplateImage(templateFile)

        let image = try ky_unwrap(composer.context.makeImage())
        XCTAssertEqual(image.width, Int(size.width))
        XCTAssertEqual(image.height, Int(size.height))
    }

    func testTemplateImageSlicesCorrectly() throws {
        let size = CGSize(width: 100, height: 50)
        let templateFile = CGContext.makeImageRepWithSize(size)
        let composer = try ImageComposer(canvasSize: size)
        try composer.addTemplateImage(templateFile)

        let image = try ky_unwrap(composer.context.makeImage())
        let slices = try ImageWriter.sliceImage(image, with: NSSize(width: 20, height: 50))
        XCTAssertEqual(slices.count, 5)
        for slice in slices {
            XCTAssertEqual(slice.width, 20)
            XCTAssertEqual(slice.height, 50)
        }
    }

    func testCanRenderStringsInContext() throws {
        let size = CGSize(width: 100, height: 200)
        let textData = try TextData.goodData.makeProcessedData(size: size)

        let composer = try ImageComposer(canvasSize: size)
        let strings: [AssociatedString] = [(string: "Some testing title", data: textData)]
        XCTAssertNoThrow(try composer.addStrings(
            strings,
            maxFontSizeByGroup: [:],
            font: .systemFont(ofSize: 20),
            color: .red,
            maxFontSize: 30))
    }

}
