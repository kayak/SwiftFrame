import Foundation
import XCTest

@testable import SwiftFrameCore

class PluralizerTests: XCTestCase {

    func testPluralizer_ProducesSingularString_WhenSpecifyingOne() {
        XCTAssertEqual(Pluralizer.pluralize(1, singular: "slice", plural: "slices"), "1 slice")
    }

    func testPluralizer_ProducesPluralString_WhenSpecifyingBigNumber() {
        XCTAssertEqual(Pluralizer.pluralize(32, singular: "slice", plural: "slices"), "32 slices")
    }

    func testPluralizer_ProducesPluralString_WhenSpecifyingZero() {
        XCTAssertEqual(Pluralizer.pluralize(0, singular: "slice", plural: "slices"), "0 slices")
    }

    func testPluralizer_ProducesZeroString_WhenSpecifyingZero() {
        XCTAssertEqual(Pluralizer.pluralize(0, singular: "slice", plural: "slices", zero: "bogus"), "0 bogus")
    }

}
