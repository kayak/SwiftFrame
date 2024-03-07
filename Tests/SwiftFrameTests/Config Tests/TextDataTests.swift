import Foundation
import XCTest
@testable import SwiftFrameCore

class TextDataTests: BaseTestCase {

    func testTextData_IsValid() throws {
        let size = CGSize(width: 200, height: 200)
        let processedData = try TextData.validData.makeProcessedData(size: size)

        XCTAssertNoThrow(try processedData.validate())
    }

    func testTextData_IsInvalid_WhenTextBoundsAreInvalid() throws {
        XCTAssertThrowsError(try TextData.invalidTextBounds.validate())
    }

}
