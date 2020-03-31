import Foundation
@testable import SwiftFrameCore

public typealias JSONDictionary = [String: Encodable]

struct TestingUtility {

    static func writeMockScreenshot(locale: String, deviceSuffix: String) throws {
        let rep = CGContext.makeImageRepWithSize(.square100Pixels)
        guard let cgImage = rep.cgImage else {
            throw NSError(description: "Could not make CGImage from Bitmap")
        }

        let url = URL(fileURLWithPath: "testing/screenshots/").appendingPathComponent(locale)
        try ImageWriter.write(cgImage, to: url, fileName: deviceSuffix, format: .png)
    }

    static func writeMockTemplateFile(deviceSuffix: String, gapWidth: Int) throws {
        let rep = CGContext.makeImageRepWithSize(.make100PixelsSize(with: gapWidth, numberOfGaps: 4))
        guard let cgImage = rep.cgImage else {
            throw NSError(description: "Could not make CGImage from Bitmap")
        }

        let url = URL(fileURLWithPath: "testing/")
        try ImageWriter.write(cgImage, to: url, fileName: "templatefile-\(deviceSuffix)", format: .png)
    }

    static func setupMockDirectoryWithScreenshots(gapWidth: Int = 0) throws {
        let devices = ["debug_device1", "debug_device2"]
        let locales = ["en", "de", "fr"]
        try devices.forEach { device in
            try writeMockTemplateFile(deviceSuffix: device, gapWidth: gapWidth)
        }

        try locales.forEach { locale in
            try devices.forEach { deviceString in
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

        try locales.forEach {
            let filePath = URL(fileURLWithPath: "testing/strings/\($0).strings")
            let data = try fileContent.ky_data(using: .utf8)

            try data.ky_write(to: filePath)
        }
    }

}
