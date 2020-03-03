import Foundation
import XCTest
@testable import SwiftFrameCore

class ImageLoaderTests: XCTestCase {

    func testLoadImage() throws {
        let rep = makeImageRepresentationWithSize(.square100Pixels)
        let cgImage = try XCTUnwrap(rep.cgImage)

        try ImageWriter.write(cgImage, to: "testing/", locale: "en", deviceID: "testing_device", format: .png)
        XCTAssertNoThrow(try ImageLoader().loadImage(atPath: "testing/en/en-testing_device.png"))

        try TestingUtility.clearTestingDirectory()
    }

}
