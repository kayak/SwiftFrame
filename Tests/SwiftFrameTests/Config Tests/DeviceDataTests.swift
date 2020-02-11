import Foundation
import XCTest
@testable import SwiftFrameCore

class DeviceDataTests: XCTestCase {

    func testValidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try DeviceData.goodData.makeProcessedData()

        XCTAssertNoThrow(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvalidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try DeviceData.invalidData.makeProcessedData()

        XCTAssertThrowsError(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

}
