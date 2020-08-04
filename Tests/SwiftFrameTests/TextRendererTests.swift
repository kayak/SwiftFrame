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
            alignment: TextAlignment(horizontal: .center, vertical: .top),
            maxSize: 400,
            size: veryLargeSize)

        XCTAssertEqual(maxSize, 400 - TextRenderer.pointSizeTolerance)
    }

    func testBoxTooSmall() {
        let renderer = TextRenderer()
        let smallSize = CGSize(width: 1, height: 1)

        XCTAssertThrowsError(try renderer.maximumFontSizeThatFits(
            string: "Some testing string",
            font: NSFont.systemFont(ofSize: 200),
            alignment: TextAlignment(horizontal: .center, vertical: .top),
            maxSize: 400,
            size: smallSize))
    }

    func testRenderTitle() throws {
        let renderer = TextRenderer()
        let size = CGSize(width: 100, height: 100)
        let rect = NSRect(x: 10, y: 10, width: 80, height: 80)

        let context = CGContext.with(size: size)
        try renderer.render(
            text: "Some title",
            font: .systemFont(ofSize: 20),
            color: .red,
            alignment: TextAlignment(horizontal: .center, vertical: .top),
            rect: rect,
            context: context)
    }

}
