import Foundation

@testable import SwiftFrameCore

typealias JSONDictionary = [String: Encodable]

struct TestingUtility {

    static func writeMockScreenshot(locale: String, deviceSuffix: String) throws {
        let rep = try GraphicsContext(size: .square100Pixels).cg.makePlainWhiteImageRep()
        guard let cgImage = rep.cgImage else {
            throw NSError(description: "Could not make CGImage from Bitmap")
        }

        let url = URL(fileURLWithPath: "testing/screenshots/")
            .appendingPathComponent(locale)
            .appendingPathComponent(deviceSuffix)
            .appendingPathExtension(FileFormat.png.fileExtension)
        try ImageWriter.writeImage(cgImage, to: [url], format: .png)
    }

    static func writeMockTemplateFile(deviceSuffix: String, gapWidth: Int) throws {
        let rep = try GraphicsContext(size: .make100PixelsSize(with: gapWidth, numberOfGaps: 4)).cg.makePlainWhiteImageRep()
        guard let cgImage = rep.cgImage else {
            throw NSError(description: "Could not make CGImage from Bitmap")
        }

        let url = URL(fileURLWithPath: "testing/templatefile-\(deviceSuffix).png")
        try ImageWriter.writeImage(cgImage, to: [url], format: .png)
    }

    static func setupMockDirectoryWithScreenshots(gapWidth: Int = 0) throws {
        let devices = ["debug_device1", "debug_device2"]
        let locales = ["en", "de", "fr"]
        for device in devices {
            try writeMockTemplateFile(deviceSuffix: device, gapWidth: gapWidth)
        }

        for locale in locales {
            for deviceString in devices {
                try writeMockScreenshot(locale: locale, deviceSuffix: deviceString)
            }
        }

        try writeStringFiles(for: locales)
    }

    static func clearTestingDirectory() throws {
        if FileManager.default.fileExists(atPath: "testing") {
            try FileManager.default.removeItem(atPath: "testing")
        }
    }

    static func writeStringFiles(for locales: [String]) throws {
        let fileContent = StringFilesContainer.goodData.makeStringFileContent()

        for locale in locales {
            let filePath = URL(fileURLWithPath: "testing/strings/\(locale).strings")
            let data = try fileContent.ky_data(using: .utf8)

            try data.ky_write(to: filePath)
        }
    }

}
