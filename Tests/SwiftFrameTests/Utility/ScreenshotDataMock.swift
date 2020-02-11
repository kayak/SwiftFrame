import Foundation
import SwiftFrameCore

extension ScreenshotData {

    static var goodData: Self {
        ScreenshotData(
            screenshotName: "debug_device1.png",
            bottomLeft: Point(x: 10, y: 10),
            bottomRight: Point(x: 40, y: 10),
            topLeft: Point(x: 10, y: 200),
            topRight: Point(x: 40, y: 200))
    }

}
