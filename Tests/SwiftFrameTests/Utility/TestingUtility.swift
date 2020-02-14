import Foundation
@testable import SwiftFrameCore

public typealias JSONDictionary = [String : Encodable]

struct TestingUtility {

    static func writeMockScreenshot(locale: String, deviceSuffix: String) throws {
        let rep = makeImageRepresentationWithSize(.square100Pixels)
        guard let cgImage = rep.cgImage else {
            throw NSError(description: "Could not make CGImage from Bitmap")
        }

        let url = URL(fileURLWithPath: "testing/screenshots/").appendingPathComponent(locale)
        try ImageWriter.write(cgImage, to: url, fileName: deviceSuffix, format: .png)
    }

    static func writeMockTemplateFile(deviceSuffix: String) throws {
        let rep = makeImageRepresentationWithSize(.square100Pixels)
        guard let cgImage = rep.cgImage else {
            throw NSError(description: "Could not make CGImage from Bitmap")
        }

        let url = URL(fileURLWithPath: "testing/")
        try ImageWriter.write(cgImage, to: url, fileName: "templatefile-\(deviceSuffix)", format: .png)
    }

    static func setupMockDirectoryWithScreenshots() throws {
        let devices = ["debug_device1", "debug_device2"]
        let locales = ["en", "de", "fr"]
        try devices.forEach { device in
            try writeMockTemplateFile(deviceSuffix: device)
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

extension Dictionary where Value == String, Key == String {

    func makeStringFileContent() -> String {
        let strings: [String] = keys.sorted().compactMap {
            guard let element = self[$0] else {
                return nil
            }
            return [$0, element + ";"].joined(separator: " = ")
        }
        return strings.joined(separator: "\n")
    }

}

