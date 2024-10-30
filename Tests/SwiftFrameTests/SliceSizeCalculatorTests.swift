import XCTest

@testable import SwiftFrameCore

final class SliceSizeCalculatorTests: BaseTestCase {

    func testSliceSizeCalculator_ProducesFiveSlices_WhenNotUsingGapWidth() throws {
        let templateSize = CGSize(width: 100, height: 50)

        let calculatedSliceSize = try SliceSizeCalculator.calculateSliceSize(
            templateImageSize: templateSize,
            numberOfSlices: 5,
            gapWidth: nil
        )
        XCTAssertEqual(calculatedSliceSize, CGSize(width: 20, height: 50))
    }

    func testSliceSizeCalculator_ProducesFiveSlices_WhenUsingGapWidth() throws {
        let templateSize = CGSize(width: 100, height: 50)

        let calculatedSliceSize = try SliceSizeCalculator.calculateSliceSize(
            templateImageSize: templateSize,
            numberOfSlices: 5,
            gapWidth: 5
        )
        XCTAssertEqual(calculatedSliceSize, CGSize(width: 16, height: 50))
    }

    func testSliceSizeCalculator_ThrowsError_WhenTotalWidthIsNotEnough() {
        let templateSize = CGSize(width: 24, height: 50)

        XCTAssertThrowsError(
            try SliceSizeCalculator.calculateSliceSize(
                templateImageSize: templateSize,
                numberOfSlices: 7,
                gapWidth: 6
            )
        )
    }

}
