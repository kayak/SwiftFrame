import Foundation
import XCTest
@testable import SwiftFrameCore

class ConfigTests: XCTestCase {

    func testGoodData() throws {
        try setupMockDirectoryWithScreenshots()

        XCTAssertNoThrow(try ConfigFile(from: ConfigContainer.goodData))
        try clearTestingDirectory()
    }

    func testBadData() throws {
        try setupMockDirectoryWithScreenshots()

        XCTAssertThrowsError(try ConfigFile(from: ConfigContainer.badData))
        try clearTestingDirectory()
    }

    func testValidData() throws {
        try setupMockDirectoryWithScreenshots()

        let data = try ConfigFile(from: ConfigContainer.goodData)
        XCTAssertNoThrow(try data.validate())
        try clearTestingDirectory()
    }

    func testInvalidData() throws {
        try setupMockDirectoryWithScreenshots()

        let data = try ConfigFile(from: ConfigContainer.invalidData)
        XCTAssertThrowsError(try data.validate())
        try clearTestingDirectory()
    }

}
