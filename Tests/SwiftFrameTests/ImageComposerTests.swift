import Foundation
import XCTest
@testable import SwiftFrameCore

class ImageComposerTests: XCTestCase {

    func testRenderTemplateFile() throws {
        let size = CGSize(width: 100, height: 50)
        let templateFile = try GraphicsContext(size: size).cg.makePlainWhiteImageRep()
        let composer = try ImageComposer(canvasSize: size)
        try composer.addTemplateImage(templateFile)

        let image = try ky_unwrap(composer.context.cg.makeImage())
        XCTAssertEqual(image.width, Int(size.width))
        XCTAssertEqual(image.height, Int(size.height))
    }

    func testTemplateImageSlicesCorrectly() throws {
        let size = CGSize(width: 100, height: 50)
        let templateFile = try GraphicsContext(size: size).cg.makePlainWhiteImageRep()
        let composer = try ImageComposer(canvasSize: size)
        try composer.addTemplateImage(templateFile)

        let image = try ky_unwrap(composer.context.cg.makeImage())
        let slices = try ImageWriter.sliceImage(image, with: NSSize(width: 20, height: 50), gapWidth: 0)
        XCTAssertEqual(slices.count, 5)
        for slice in slices {
            XCTAssertEqual(slice.width, 20)
            XCTAssertEqual(slice.height, 50)
        }
    }

}
