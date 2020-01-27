import Foundation
import XCTest
@testable import SwiftFrameCore

class ColorHexTests: XCTestCase {

    func testCorrectColor() throws {
        let color = try NSColor(hexString: "#ff0000")
        XCTAssertEqual(color, NSColor.red)
    }

    func testBadHexString() {
        XCTAssertThrowsError(try NSColor(hexString: "#ff99uw"))
    }

    func testGrayscaleColor() {
        XCTAssertNoThrow(try NSColor(hexString: "#fff"))
    }

}
