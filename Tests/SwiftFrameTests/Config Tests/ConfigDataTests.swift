import Foundation
import XCTest
@testable import SwiftFrameCore

class ConfigDataTests: BaseTestCase {

    func testValidData() throws {
        var data = ConfigData.goodData
        try data.process()

        XCTAssertNoThrow(try data.validate())
    }

    func testSkippedLocalesData() throws {
        var data = ConfigData.skippedLocaleData
        try data.process()

        XCTAssertNoThrow(try data.validate())

        guard let keys = data.deviceData.first?.screenshotsGroupedByLocale.keys else {
            throw NSError(description: "No device data supplied")
        }
        XCTAssertEqual(Array(keys), ["de"])
    }

    func testEnglishOnlyData() throws {
        var data = ConfigData.englishOnlyData
        try data.process()

        XCTAssertNoThrow(try data.validate())

        guard let keys = data.deviceData.first?.screenshotsGroupedByLocale.keys else {
            throw NSError(description: "No device data supplied")
        }
        XCTAssertEqual(Array(keys), ["en"])
    }

    func testInvalidData() throws {
        var data = ConfigData.invalidData
        try data.process()

        XCTAssertThrowsError(try data.validate())
    }

}
