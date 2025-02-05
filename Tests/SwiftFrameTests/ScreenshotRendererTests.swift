import Foundation
import XCTest

@testable import SwiftFrameCore

class ScreenshotRendererTests: XCTestCase {

    func testRenderScreenshot() throws {
        let size = CGSize(width: 100, height: 100)
        let context = try GraphicsContext(size: size)
        let rep = context.cg.makePlainWhiteImageRep()

        let mockScreenshotData = ScreenshotData.goodData

        let renderer = ScreenshotRenderer()
        try renderer.render(
            screenshot: rep,
            with: mockScreenshotData,
            in: context
        )
    }

}
