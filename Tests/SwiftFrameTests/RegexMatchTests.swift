import Foundation
import XCTest

@testable import SwiftFrameCore

class RegexMatchTests: XCTestCase {

    private let urls: [URL] = [
        URL(fileURLWithPath: "strings/en.strings"),
        URL(fileURLWithPath: "strings/de.strings"),
        URL(fileURLWithPath: "strings/fr.strings"),
        URL(fileURLWithPath: "strings/ru.strings"),
    ]

    func testAllURLs() throws {
        let filteredURLs = try urls.filterByFileOrFoldername(regex: nil)
        XCTAssertEqual(filteredURLs, urls)
    }

    func testFranceFilteredOut() throws {
        let regex = try Regex("^(?!fr$)\\w*$")
        let filteredURLs = try urls.filterByFileOrFoldername(regex: regex)

        guard ky_assertEqual(filteredURLs.count, 3) else {
            return
        }
        XCTAssertTrue(filteredURLs[0].absoluteString.hasSuffix("en.strings"))
        XCTAssertTrue(filteredURLs[1].absoluteString.hasSuffix("de.strings"))
        XCTAssertTrue(filteredURLs[2].absoluteString.hasSuffix("ru.strings"))
    }

    func testFranceAndRussiaFilteredOut() throws {
        let regex = try Regex("^(?!fr|ru$)\\w*$")
        let filteredURLs = try urls.filterByFileOrFoldername(regex: regex)

        guard ky_assertEqual(filteredURLs.count, 2) else {
            return
        }
        XCTAssertTrue(filteredURLs[0].absoluteString.hasSuffix("en.strings"))
        XCTAssertTrue(filteredURLs[1].absoluteString.hasSuffix("de.strings"))
    }

    func testOnlyRussiaAndFrance() throws {
        let regex = try Regex("ru|fr")
        let filteredURLs = try urls.filterByFileOrFoldername(regex: regex)

        guard ky_assertEqual(filteredURLs.count, 2) else {
            return
        }
        XCTAssertEqual(filteredURLs[0].lastPathComponent, "fr.strings")
        XCTAssertEqual(filteredURLs[1].lastPathComponent, "ru.strings")
    }

}

// with this wrapper method we can make tests fail and return a boolean at the same time
// since simply asserting would not stop the test
private func ky_assertEqual<T: Equatable>(_ value1: T, _ value2: T) -> Bool {
    if value1 != value2 {
        XCTFail("\(value1) is not equal to \(value2)")
    }
    return value1 == value2
}
