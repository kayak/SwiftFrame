import Foundation
import XCTest
@testable import SwiftFrameCore

class ImageLoaderTests: XCTestCase {

    func testLoadImage() throws {
        let rep = makeImageRepresentationWithSize(.square100Pixels)
        guard let cgImage = rep.cgImage else {
            throw NSError(description: "Could not make CGImage from Bitmap")
        }

        try ImageWriter().write(cgImage, to: "temp/", locale: "en", deviceID: "testing_device")
        XCTAssertNoThrow(try ImageLoader().loadImage(atPath: "temp/en/en-testing_device.png"))
        try FileManager.default.removeItem(atPath: "temp")
    }

}

extension CGSize {
    static let square100Pixels: CGSize = CGSize(width: 100, height: 100)
}