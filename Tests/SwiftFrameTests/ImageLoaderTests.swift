import Foundation
import XCTest
@testable import SwiftFrameCore

class ImageLoaderTests: BaseTest {

    func testLoadImage() throws {
        let context = try GraphicsContext(size: .square100Pixels)
        let rep = context.cg.makePlainWhiteImageRep()
        let cgImage = try ky_unwrap(rep.cgImage)

        try ImageWriter.write(cgImage, to: "testing/", locale: "en", deviceID: "testing_device", format: .png)
        XCTAssertNoThrow(try ImageLoader().loadImage(atPath: "testing/en/en-testing_device.png"))
    }

}
