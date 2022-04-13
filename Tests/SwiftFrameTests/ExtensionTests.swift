import Foundation
import XCTest
@testable import SwiftFrameCore

class ExtensionTests: XCTestCase {
    
    func testStringWithHTMLTagsIsFlagged() {
        let testString1 = "This is a <b>test</b>"
        let testString2 = "This is a <i>test</i>"
        let testString3 = "This <i>is a<i/> <b>test</b>"
        
        XCTAssertTrue(testString1.ky_containsHTMLTags())
        XCTAssertTrue(testString2.ky_containsHTMLTags())
        XCTAssertTrue(testString3.ky_containsHTMLTags())
    }
    
    func testStringWithoutHTMLTagsIsNotFlagged() {
        let testString1 = "This is a test"
        let testString2 = "1 < 3 means one is smaller than three"
        let testString3 = "3 > 1 means three is larger than one"
        let testString4 = "This i> kind of looks like html tags, but is not </ "
        
        XCTAssertFalse(testString1.ky_containsHTMLTags())
        XCTAssertFalse(testString2.ky_containsHTMLTags())
        XCTAssertFalse(testString3.ky_containsHTMLTags())
        XCTAssertFalse(testString4.ky_containsHTMLTags())
    }

}
