import Foundation

struct DeviceData: Decodable, ConfigValidatable {
    let outputSuffix: String
    let screenshots: URL
    let templateFile: URL
    let screenshotData: [ScreenshotData]
    let textData: [TextData]

    func validate() throws {

    }

    func printSummary() {

    }
}
