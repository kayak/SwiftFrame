import Foundation
import XCTest
@testable import SwiftFrameCore

class FrameTests: XCTestCase {

    func testPrefersSpecifiedViewport() {
        guard let frame = try? Frame(
            path: Bundle(for: self.classForCoder).path(forResource: "iPhone6s", ofType: "png")!,
            padding: 0,
            hasNotch: false,
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
            hasNotch: false,
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

    func computeViewportRect(from frame: NSImage, hasNotch: Bool) -> NSRect? {
        return NSRect(x: 1, y: 2, width: 3, height: 4)
    }

    func computeViewportMask(from frame: NSImage, with viewport: NSRect) throws -> NSImage? {
        return nil
    }

}
