import Foundation
import XCTest
@testable import SwiftFrameCore

class TextDataTests: KYBaseTest {

    func testValidData() throws {
        let size = CGSize(width: 200, height: 200)
        let data = try TextData.goodData.makeProcessedData(size: size)

        XCTAssertNoThrow(try data.validate())
    }

    func testInvalidData() throws {
        XCTAssertThrowsError(try TextData.invalidData.validate())
    }

}
