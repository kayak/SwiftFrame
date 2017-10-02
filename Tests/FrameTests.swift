import Foundation
import XCTest

class FrameTests: XCTestCase {

    func testPrefersSpecifiedViewport() {
        guard let frame = try? Frame(
            path: Bundle(for: self.classForCoder).path(forResource: "iPhone6s", ofType: "png")!,
            padding: 0,
            namePattern: ".*",
            viewport: NSRect(x: 0, y: 0, width: 100, height: 100),
            viewportComputer: ViewportComputerMock())
        else {
            XCTFail()
            return
        }
        XCTAssertEqual(frame.viewport, NSRect(x: 0, y: 0, width: 100, height: 100))
    }

    func testComputesViewportIfNoneSpecified() {
        guard let frame = try? Frame(
            path: Bundle(for: self.classForCoder).path(forResource: "iPhone6s", ofType: "png")!,
            padding: 0,
            namePattern: ".*",
            viewportComputer: ViewportComputerMock())
        else {
            XCTFail()
            return
        }
        XCTAssertEqual(frame.viewport, NSRect(x: 1, y: 2, width: 3, height: 4))
    }

}

private struct ViewportComputerMock: ViewportComputerProtocol {

    func compute(from image: NSImage) -> NSRect? {
        return NSRect(x: 1, y: 2, width: 3, height: 4)
    }

}
