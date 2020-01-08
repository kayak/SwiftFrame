import Foundation
import XCTest
@testable import SwiftFrameCore

class ImageLoaderTests: XCTestCase {

    func testCanLoadImage() throws {
        let loader = ImageLoader()
        let image = makeImageRepresentationWithSize(CGSize(width: 50, height: 50))
        image.cgImage
    }

}
