import Foundation

struct ScreenshotData: Decodable, ConfigValidatable {
    let screenshotName: String
    let bottomLeft: Point
    let bottomRight: Point
    let topLeft: Point?
    let topRight: Point?
    let rotationAngle: Double?

    func validate() throws {
        if (topLeft == nil || topRight == nil) && rotationAngle == nil {
            throw NSError(description: "No rotation angle was specified, which is required if only supplying bottom corners")
        }
    }

    func printSummary(insetByTabs tabs: Int) {
        print(CommandLineFormatter.formatKeyValue("Screenshot Name", value: screenshotName, insetBy: tabs))
        print(CommandLineFormatter.formatKeyValue("Bottom Left", value: bottomLeft.formattedString, insetBy: tabs + 1))
        print(CommandLineFormatter.formatKeyValue("Bottom Right", value: bottomRight.formattedString, insetBy: tabs + 1))

        if let topLeft = topLeft {
            print(CommandLineFormatter.formatKeyValue("Top Left", value: topLeft.formattedString, insetBy: tabs + 1))
        }

        if let topRight = topRight {
            print(CommandLineFormatter.formatKeyValue("Top Right", value: topRight.formattedString, insetBy: tabs + 1))
        }

        if let rotation = rotationAngle {
            print(CommandLineFormatter.formatKeyValue("Rotation Angle", value: rotation, insetBy: tabs + 1))
        }
    }
}
