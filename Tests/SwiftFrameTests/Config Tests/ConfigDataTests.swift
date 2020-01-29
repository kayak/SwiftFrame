import Foundation
import XCTest
@testable import SwiftFrameCore

class ConfigDataTests: XCTestCase {

    func testGoodData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertNoThrow(try ConfigDataMock.makeGoodData())
        try TestingUtility.clearTestingDirectory()
    }

    func testBadData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertThrowsError(try ConfigData(from: ConfigDataMock.badData))
        try TestingUtility.clearTestingDirectory()
    }

    func testValidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try ConfigDataMock.makeGoodData()

        XCTAssertNoThrow(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvalidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try ConfigDataMock.makeInvalidData()

        XCTAssertThrowsError(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvertedData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try ConfigDataMock.makeInvertedData()

        XCTAssertNoThrow(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

}
