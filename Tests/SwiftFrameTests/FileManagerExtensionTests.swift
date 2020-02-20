import Foundation
import XCTest
@testable import SwiftFrameCore

class FileManagerExtensionTests: XCTestCase {

    func testIsWritableFile() {
        XCTAssertTrue(FileManager.default.ky_isWritableDirectory(atPath: "testing/some/deep/directory"))
    }

    func testNonWritableFile() {
        XCTAssertFalse(FileManager.default.ky_isWritableDirectory(atPath: "testing/some/deep/directory.txt"))
    }

    func testDirectoryWithPathExtension() {
        XCTAssertTrue(FileManager.default.ky_isWritableDirectory(atPath: "testing/some/deep/directory.txt/"))
    }

}
