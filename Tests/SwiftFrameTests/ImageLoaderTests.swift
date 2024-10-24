import Foundation
import XCTest

@testable import SwiftFrameCore

class ImageLoaderTests: BaseTestCase {

    func testLoadImage() throws {
        let context = try GraphicsContext(size: .square100Pixels)
        let rep = context.cg.makePlainWhiteImageRep()
        let cgImage = try XCTUnwrap(rep.cgImage)

        let url = URL(fileURLWithPath: "testing/en/en-testing_device.png")

        try ImageWriter.writeImage(cgImage, to: [url], format: .png)
        XCTAssertNoThrow(try ImageLoader().loadImage(atPath: "testing/en/en-testing_device.png"))
    }

}
