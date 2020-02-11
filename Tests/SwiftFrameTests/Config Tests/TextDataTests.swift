import Foundation
import XCTest
@testable import SwiftFrameCore

class TextDataTests: XCTestCase {

    func testValidData() throws {
        let size = CGSize(width: 200, height: 200)
        let data = try TextData.goodData.makeProcessedData(size: size)

        XCTAssertNoThrow(try data.validate())
        try TestingUtility.clearTestingDirectory()
    }

    func testInvalidData() throws {
        XCTAssertThrowsError(try TextData.invalidData.validate())
        try TestingUtility.clearTestingDirectory()
    }

}
