import Foundation
import XCTest
@testable import SwiftFrameCore

class DeviceDataTests: XCTestCase {

    func testGoodData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertNoThrow(try DeviceDataContainer.makeGoodData())
        try TestingUtility.clearTestingDirectory()
    }

    func testBadData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertThrowsError(try DeviceData(from: DeviceDataContainer.badData))
        try TestingUtility.clearTestingDirectory()
    }

    func testValidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try DeviceDataContainer.makeGoodData()
        XCTAssertNoThrow(try data.validate())

        try TestingUtility.clearTestingDirectory()
    }

    func testInvalidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try DeviceDataContainer.makeInvalidData()
        XCTAssertThrowsError(try data.validate())

        try TestingUtility.clearTestingDirectory()
    }

    func testInvertedData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try DeviceDataContainer.makeInvertedData()
        XCTAssertNoThrow(try data.validate())

        try TestingUtility.clearTestingDirectory()
    }

}
