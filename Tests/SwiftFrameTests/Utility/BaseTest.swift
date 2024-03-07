import Foundation
import XCTest

class BaseTest: XCTestCase {

    override func setUpWithError() throws {
        try TestingUtility.setupMockDirectoryWithScreenshots()
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try TestingUtility.clearTestingDirectory()
        try super.tearDownWithError()
    }

}
