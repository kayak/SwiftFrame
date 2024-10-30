import Foundation
import XCTest

@testable import SwiftFrameCore

class TextRendererTests: XCTestCase {

    func testTextAtMaxSize() throws {
        let veryLargeSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 2000)
        let maxSize = try TextRenderer.maximumFontSizeThatFits(
            string: "Some testing string",
            font: NSFont.systemFont(ofSize: 200),
            alignment: TextAlignment(horizontal: .center, vertical: .top),
            maxSize: 400,
            size: veryLargeSize
        )

        XCTAssertEqual(maxSize, 400)
    }

    func testBoxTooSmall() {
        let smallSize = CGSize(width: 1, height: 1)

        XCTAssertThrowsError(
            try TextRenderer.maximumFontSizeThatFits(
                string: "Some testing string",
                font: NSFont.systemFont(ofSize: 200),
                alignment: TextAlignment(horizontal: .center, vertical: .top),
                maxSize: 400,
                size: smallSize
            )
        )
    }

    func testBottomAlignedRect() throws {
        let renderer = TextRenderer()
        let size = CGSize(width: 60, height: 60)
        let rect = NSRect(x: 10, y: 10, width: 80, height: 80)

        let alignedRect = try renderer.calculateAlignedRect(
            size: size,
            outerFrame: rect,
            alignment: .init(horizontal: .center, vertical: .bottom)
        )

        XCTAssertEqual(alignedRect.origin, rect.origin)
        XCTAssertEqual(alignedRect.height, size.height)
    }

    func testTopAlignedRect() throws {
        let renderer = TextRenderer()
        let size = CGSize(width: 60, height: 60)
        let rect = NSRect(x: 10, y: 10, width: 80, height: 80)

        let alignedRect = try renderer.calculateAlignedRect(
            size: size,
            outerFrame: rect,
            alignment: .init(horizontal: .center, vertical: .top)
        )

        XCTAssertEqual(alignedRect.origin.y, rect.origin.y + (rect.height - alignedRect.height))
        XCTAssertEqual(alignedRect.height, size.height)
    }

    func testCenterAlignedRect() throws {
        let renderer = TextRenderer()
        let size = CGSize(width: 60, height: 60)
        let rect = NSRect(x: 10, y: 10, width: 80, height: 80)

        let alignedRect = try renderer.calculateAlignedRect(
            size: size,
            outerFrame: rect,
            alignment: .init(horizontal: .center, vertical: .center)
        )

        XCTAssertEqual(alignedRect.origin.y, rect.origin.y + ((rect.height - alignedRect.height) / 2))
        XCTAssertEqual(alignedRect.height, size.height)
    }

}
