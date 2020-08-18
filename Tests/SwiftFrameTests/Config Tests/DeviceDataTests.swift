import Foundation
import XCTest
@testable import SwiftFrameCore

class DeviceDataTests: BaseTest {

    func testValidData() throws {
        let data = try DeviceData.goodData.makeProcessedData(localesRegex: nil)
        XCTAssertNoThrow(try data.validate())
    }

    func testGapDataValid() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots(gapWidth: 16)

        let data = try DeviceData.gapData.makeProcessedData(localesRegex: nil)
        XCTAssertNoThrow(try data.validate())
    }

    func testGapDataInvalid() throws {
        let data = try DeviceData.gapData.makeProcessedData(localesRegex: nil)
        XCTAssertThrowsError(try data.validate())
    }

    func testInvalidData() throws {
        let data = try DeviceData.invalidData.makeProcessedData(localesRegex: nil)
        XCTAssertThrowsError(try data.validate())
    }

    func testMismatchingDeviceSizeData() throws {
        let data = try DeviceData.mismatchingDeviceSizeData.makeProcessedData(localesRegex: nil)
        XCTAssertNoThrow(try data.validate())
    }

    func testFaultyMismatchingDeviceSizeData() throws {
        let data = try DeviceData.faultyMismatchingDeviceSizeData.makeProcessedData(localesRegex: nil)
        XCTAssertThrowsError(try data.validate())
    }

}
