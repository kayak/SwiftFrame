import Foundation
import XCTest
@testable import SwiftFrameCore

class ConfigDataTests: XCTestCase {

    func testGoodData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertNoThrow(try ConfigContainerMock.makeGoodData())
        try TestingUtility.clearTestingDirectory()
    }

    func testBadData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        XCTAssertThrowsError(try ConfigData(from: ConfigContainerMock.badData))
        try TestingUtility.clearTestingDirectory()
    }

    func testValidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try ConfigContainerMock.makeGoodData()
        XCTAssertNoThrow(try data.validate())

        try TestingUtility.clearTestingDirectory()
    }

    func testInvalidData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try ConfigContainerMock.makeInvalidData()
        XCTAssertThrowsError(try data.validate())

        try TestingUtility.clearTestingDirectory()
    }

    func testInvertedData() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()

        let data = try ConfigContainerMock.makeInvertedData()
        XCTAssertNoThrow(try data.validate())

        try TestingUtility.clearTestingDirectory()
    }

}
