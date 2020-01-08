import Foundation
import XCTest
@testable import SwiftFrameCore

class TextRendererTests: XCTestCase {

    func testTextAtMaxSize() throws {
        let renderer = TextRenderer()

        let veryLargeSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 2000)
        let maxSize = try renderer.maximumFontSizeThatFits(
            string: "Some testing string",
            size: veryLargeSize,
            font: NSFont.systemFont(ofSize: 200),
            maxFontSize: 400)

        XCTAssertEqual(maxSize, 400)
    }

}
