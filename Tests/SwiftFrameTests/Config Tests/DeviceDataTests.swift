import Foundation
import XCTest
@testable import SwiftFrameCore

class DeviceDataTests: XCTestCase {

    func testGoodData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertNoThrow(try DeviceDataMock.makeGoodData())
        try TestingUtility.clearTestingDirectory()
    }

    func testBadData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertThrowsError(try DeviceData(from: DeviceDataMock.badData))
        try TestingUtility.clearTestingDirectory()
    }

    func testValidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try DeviceDataMock.makeGoodData()

        XCTAssertNoThrow(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvalidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try DeviceDataMock.makeInvalidData()

        XCTAssertThrowsError(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvertedData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try DeviceDataMock.makeInvertedData()

        XCTAssertNoThrow(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

}
