import Foundation
import XCTest
@testable import SwiftFrameCore

class ConfigDataTests: KYBaseTest {

    func testValidData() throws {
        var data = ConfigData.goodData
        try data.process()

        XCTAssertNoThrow(try data.validate())
    }

    func testInvalidData() throws {
        var data = ConfigData.invalidData
        try data.process()

        XCTAssertThrowsError(try data.validate())
    }

}
