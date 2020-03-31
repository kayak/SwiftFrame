import Foundation
import XCTest

class BaseTest: XCTestCase {

    override func setUp() {
        super.setUp()

        do {
            try TestingUtility.setupMockDirectoryWithScreenshots()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        super.tearDown()

        do {
            try TestingUtility.clearTestingDirectory()
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

}
