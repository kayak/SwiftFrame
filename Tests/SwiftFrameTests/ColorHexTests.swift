import Foundation
import XCTest

@testable import SwiftFrameCore

class ColorHexTests: XCTestCase {

    func testCorrectColor() throws {
        let color = try NSColor(hexString: "#ff0000")
        let referenceColor = NSColor(red: 1.00, green: 0.00, blue: 0.00, alpha: 1.00)
        XCTAssertEqual(color, referenceColor)
    }

    func testBadHexString() {
        XCTAssertThrowsError(try NSColor(hexString: "#ff99uw"))
    }

    func testGrayscaleColor() throws {
        let color = try NSColor(hexString: "#fff")
        let referenceColor = NSColor(white: 1, alpha: 1).usingColorSpace(.sRGB)

        XCTAssertEqual(color, referenceColor)
    }

}
