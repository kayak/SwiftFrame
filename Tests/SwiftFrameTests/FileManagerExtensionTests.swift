import Foundation
import XCTest
@testable import SwiftFrameCore

class FileManagerExtensionTests: XCTestCase {

    func testIsWritableFile() {
        XCTAssertTrue(FileManager.default.ky_isWritableDirectory(atPath: "testing/some/deep/directory"))
    }

}
