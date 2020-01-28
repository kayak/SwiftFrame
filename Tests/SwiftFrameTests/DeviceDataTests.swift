import Foundation
import XCTest
@testable import SwiftFrameCore

class DeviceDataTests: XCTestCase {

    func testGoodData() throws {
        try setupMockDirectoryWithScreenshots()

        XCTAssertNoThrow(try DeviceData(from: DeviceDataContainer.goodData))
        try clearTestingDirectory()
    }

    func testBadData() throws {
        try setupMockDirectoryWithScreenshots()

        XCTAssertThrowsError(try DeviceData(from: DeviceDataContainer.badData))
        try clearTestingDirectory()
    }

    func testValidateData() throws {
        try setupMockDirectoryWithScreenshots()

        let data = try DeviceData(from: DeviceDataContainer.goodData)
        XCTAssertNoThrow(try data.validate())
        try clearTestingDirectory()
    }

    func testInvalidDataThrows() throws {
        try setupMockDirectoryWithScreenshots()

        let data = try DeviceData(from: DeviceDataContainer.invalidData)
        XCTAssertThrowsError(try data.validate())
        try clearTestingDirectory()
    }

    func testInvertedData() throws {
        try setupMockDirectoryWithScreenshots()

        let data = try DeviceData(from: DeviceDataContainer.invertedData)
        XCTAssertNoThrow(try data.validate())
        try clearTestingDirectory()
    }

}

func writeMockScreenshot(locale: String, deviceSuffix: String) throws {
    let rep = makeImageRepresentationWithSize(.square100Pixels)
    guard let cgImage = rep.cgImage else {
        throw NSError(description: "Could not make CGImage from Bitmap")
    }

    let url = URL(fileURLWithPath: "testing/screenshots/").appendingPathComponent(locale)
    try ImageWriter().write(cgImage, to: url, fileName: deviceSuffix + ".png")
}

func writeMockTemplateFile(deviceSuffix: String) throws {
    let rep = makeImageRepresentationWithSize(.square100Pixels)
    guard let cgImage = rep.cgImage else {
        throw NSError(description: "Could not make CGImage from Bitmap")
    }

    let url = URL(fileURLWithPath: "testing/")
    try ImageWriter().write(cgImage, to: url, fileName: "templatefile-\(deviceSuffix).png")
}

func setupMockDirectoryWithScreenshots() throws {
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

func clearTestingDirectory() throws {
    try FileManager.default.removeItem(atPath: "testing")
}
