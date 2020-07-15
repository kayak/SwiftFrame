import Foundation
import XCTest
@testable import SwiftFrameCore

class RegexMatchTests: XCTestCase {

    static let urls: [URL] = {
        [
            URL(fileURLWithPath: "strings/en.strings"),
            URL(fileURLWithPath: "strings/de.strings"),
            URL(fileURLWithPath: "strings/fr.strings"),
            URL(fileURLWithPath: "strings/ru.strings")
        ]
    }()

    func testAllURLs() throws {
        let urls = try RegexMatchTests.urls.filter(pattern: nil)
        XCTAssertEqual(urls, RegexMatchTests.urls)
    }

//    func testAllFilteredOut() throws {
//        let urls = try RegexMatchTests.urls.filter(pattern: nil)
//        XCTAssertTrue(urls.isEmpty)
//    }

    func testFranceFilteredOut() throws {
        let urls = try RegexMatchTests.urls.filter(pattern: "^(?!fr$)\\w*$")

        guard ky_assertEqual(urls.count, 3) else {
            return
        }
        XCTAssertTrue(urls[0].absoluteString.hasSuffix("en.strings"))
        XCTAssertTrue(urls[1].absoluteString.hasSuffix("de.strings"))
        XCTAssertTrue(urls[2].absoluteString.hasSuffix("ru.strings"))
    }

    func testOnlyRussiaAndFrance() throws {
        let urls = try RegexMatchTests.urls.filter(pattern: "ru|fr")

        guard ky_assertEqual(urls.count, 2) else {
            return
        }
        XCTAssertEqual(urls[0].lastPathComponent, "fr.strings")
        XCTAssertEqual(urls[1].lastPathComponent, "ru.strings")
    }

}

// with this wrapper method we can make tests fail and return a boolean at the same time
// since simply asserting would not stop the test
fileprivate func ky_assertEqual<T: Equatable>(_ value1: T, _ value2: T) -> Bool {
    if value1 != value2 {
        XCTFail("\(value1) is not equal to \(value2)")
    }
    return value1 == value2
}
