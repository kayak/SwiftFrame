import XCTest
@testable import SwiftFrameCore

final class SliceSizeCalculatorTests: BaseTestCase {

    func testSliceSizeCalculator_ProducesFiveSlices_WhenNotUsingGapWidth() {
        let templateSize = CGSize(width: 100, height: 50)

        let calculatedSliceSize = SliceSizeCalculator.calculateSliceSize(
            templateImageSize: templateSize,
            numberOfSlices: 5,
            gapWidth: nil
        )
        XCTAssertEqual(calculatedSliceSize, CGSize(width: 20, height: 50))
    }

    func testSliceSizeCalculator_ProducesFiveSlices_WhenUsingGapWidth() {
        let templateSize = CGSize(width: 100, height: 50)

        let calculatedSliceSize = SliceSizeCalculator.calculateSliceSize(
            templateImageSize: templateSize,
            numberOfSlices: 5,
            gapWidth: 5
        )
        XCTAssertEqual(calculatedSliceSize, CGSize(width: 16, height: 50))
    }

}
