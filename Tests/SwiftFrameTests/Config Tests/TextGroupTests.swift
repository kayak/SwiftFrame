import Foundation
import XCTest
@testable import SwiftFrameCore

class TextGroupTests: XCTestCase {

    func testSharedFontSize() throws {
        let textGroup = TextGroup.goodData

        let sharedFontSize = try textGroup.sharedFontSize(with: [], globalFont: .systemFont(ofSize: 20), globalMaxSize: 200)
        XCTAssertEqual(sharedFontSize, 200)
    }

}
