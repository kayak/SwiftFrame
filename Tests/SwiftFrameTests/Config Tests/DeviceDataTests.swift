import Foundation
import XCTest
@testable import SwiftFrameCore

class DeviceDataTests: BaseTest {

    func testValidData() throws {
        let data = try DeviceData.goodData.makeProcessedData()
        XCTAssertNoThrow(try data.validate())
    }

    func testGapDataValid() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots(gapWidth: 16)

        let data = try DeviceData.gapData.makeProcessedData()
        XCTAssertNoThrow(try data.validate())
    }

    func testGapDataInvalid() throws {
        let data = try DeviceData.gapData.makeProcessedData()
        XCTAssertThrowsError(try data.validate())
    }

    func testInvalidData() throws {
        let data = try DeviceData.invalidData.makeProcessedData()
        XCTAssertThrowsError(try data.validate())
    }

}
