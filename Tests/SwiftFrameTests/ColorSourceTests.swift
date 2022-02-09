import Foundation
import XCTest
@testable import SwiftFrameCore

class ColorSourceTests: XCTestCase {

    func testCorrectColor() throws {
        let color = try ColorSource(sourceString: "#ff0000").color
        let referenceColor = NSColor(red: 1.00, green: 0.00, blue: 0.00, alpha: 1.00)
        XCTAssertEqual(color, referenceColor)
    }

    func testBadHexString() {
        XCTAssertThrowsError(try ColorSource(sourceString: "#ff99uw"))
    }

    func testGrayscaleColor() throws {
        let color = try ColorSource(sourceString: "#fff").color
        let referenceColor = NSColor(white: 1, alpha: 1).usingColorSpace(.sRGB)

        XCTAssertEqual(color, referenceColor)
    }

    func testRGBString() throws {
        XCTAssertNoThrow(try ColorSource(sourceString: "rgba(128, 123, 123, 0.3)"))
    }

    func testRGBStringColor() throws {
        let colorSource = try ColorSource(sourceString: "rgba(255, 0, 0, 0.3)")
        XCTAssertEqual(colorSource.color.redComponent, 1.0)
        XCTAssertEqual(colorSource.color.greenComponent, 0)
        XCTAssertEqual(colorSource.color.blueComponent, 0)
        XCTAssertEqual(colorSource.color.alphaComponent, 0.3)
        XCTAssertEqual(colorSource.color, NSColor.red.withAlphaComponent(0.3))
    }

}
