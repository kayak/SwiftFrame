import Foundation
import XCTest
@testable import SwiftFrameCore

class TextRendererTests: XCTestCase {

    func testTextAtMaxSize() throws {
        let renderer = TextRenderer()

        let veryLargeSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 2000)
        let maxSize = try renderer.maximumFontSizeThatFits(
            string: "Some testing string",
            font: NSFont.systemFont(ofSize: 200),
            alignment: .center,
            maxSize: 400,
            size: veryLargeSize)

        XCTAssertEqual(maxSize, 400)
    }

    func testBoxTooSmall() {
        let renderer = TextRenderer()
        let smallSize = CGSize(width: 1, height: 1)

        XCTAssertThrowsError(try renderer.maximumFontSizeThatFits(
            string: "Some testing string",
            font: NSFont.systemFont(ofSize: 200),
            alignment: .center,
            maxSize: 400,
            size: smallSize))
    }

}
