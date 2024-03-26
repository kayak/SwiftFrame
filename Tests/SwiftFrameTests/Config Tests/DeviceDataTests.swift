import Foundation
import XCTest
@testable import SwiftFrameCore

class DeviceDataTests: BaseTestCase {

    func testDeviceData_IsValid_WhenAllDataIsValid() throws {
        let data = try DeviceData.validData().makeProcessedData(localesRegex: nil)
        XCTAssertNoThrow(try data.validate())
    }

    func testDeviceData_IsValid_WhenGapWidthIsPositive() throws {
        let data = try DeviceData.validData(gapWidth: 16).makeProcessedData(localesRegex: nil)
        XCTAssertNoThrow(try data.validate())
    }

    func testDeviceData_IsInvalid_WhenTextDataIsInvalid() throws {
        let data = try DeviceData.invalidTextData.makeProcessedData(localesRegex: nil)
        XCTAssertThrowsError(try data.validate())
    }

    func testDeviceData_IsInvalid_WhenNumberOfSlicesIsZero() throws {
        let data = try DeviceData.invalidNumberOfSlices.makeProcessedData(localesRegex: nil)
        XCTAssertThrowsError(try data.validate())
    }

    func testDeviceData_IsInvalid_WhenGapWidthNegative() throws {
        let data = try DeviceData.invalidGapWidth.makeProcessedData(localesRegex: nil)
        XCTAssertThrowsError(try data.validate())
    }

}
