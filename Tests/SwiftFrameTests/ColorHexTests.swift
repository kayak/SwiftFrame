import Foundation
import XCTest
@testable import SwiftFrameCore

class ColorHexTests: XCTestCase {

    func testCorrectColor() throws {
        let color = try NSColor(hexString: "#ff0000")
        var red: CGFloat = CGFloat.greatestFiniteMagnitude
        color.getRed(&red, green: nil, blue: nil, alpha: nil)
        XCTAssertEqual(red, 1.00)
    }

    func testBadHexString() {
        XCTAssertThrowsError(try NSColor(hexString: "#ff99uw"))
    }

    func testGrayscaleColor() throws {
        let color = try NSColor(hexString: "#fff")

        var red: CGFloat = .greatestFiniteMagnitude
        var green: CGFloat = .greatestFiniteMagnitude
        var blue: CGFloat = .greatestFiniteMagnitude

        color.getRed(&red, green: &green, blue: &blue, alpha: nil)

        XCTAssertEqual(red, 1.00)
        XCTAssertEqual(green, 1.00)
        XCTAssertEqual(blue, 1.00)
    }

}
