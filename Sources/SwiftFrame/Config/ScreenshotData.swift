import Foundation

struct ScreenshotData: Decodable, ConfigValidatable {
    let screenshotName: String
    let bottomLeft: Point
    let bottomRight: Point
    let topLeft: Point?
    let topRight: Point?
    let rotationAngle: Double?

    func validate() throws {

    }

    func printSummary() {

    }
}
