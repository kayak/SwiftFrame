import Foundation
import XCTest
@testable import SwiftFrameCore

class ScreenshotRendererTests: XCTestCase {

    func testRenderScreenshot() throws {
        let size = CGSize(width: 100, height: 100)
        let context = makeCGContext(size)
        let rep = makeImageRepresentationWithSize(size)

        let renderer = ScreenshotRenderer()
        try renderer.render(
            screenshot: rep,
            with: ScreenshotData.goodMockData,
            in: context)
    }

}
