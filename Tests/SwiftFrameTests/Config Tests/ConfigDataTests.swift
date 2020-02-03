import Foundation
import XCTest
@testable import SwiftFrameCore

class ConfigDataTests: XCTestCase {

    func testValidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        var data = ConfigData.goodData
        try data.process()

        XCTAssertNoThrow(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvalidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        var data = ConfigData.invalidData
        try data.process()

        XCTAssertThrowsError(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvertedData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        var data = ConfigData.invertedData
        try data.process()

        XCTAssertThrowsError(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

}
