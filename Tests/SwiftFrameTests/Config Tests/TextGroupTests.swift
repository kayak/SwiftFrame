import Foundation
import XCTest
@testable import SwiftFrameCore

class TextGroupTests: XCTestCase {

    func testGoodData() throws {
        XCTAssertNoThrow(try TextGroupMock.makeGoodData())
        try TestingUtility.clearTestingDirectory()
    }

    func testBadData() throws {
        XCTAssertThrowsError(try TextGroup(from: TextGroupMock.badData))
        try TestingUtility.clearTestingDirectory()
    }

    func testSharedFontSize() throws {
        let textGroup = try TextGroupMock.makeGoodData()

        let sharedFontSize = textGroup.sharedFontSize(with: [], globalFont: .systemFont(ofSize: 20), globalMaxSize: 200)
        XCTAssertEqual(sharedFontSize, 200)
    }

}
