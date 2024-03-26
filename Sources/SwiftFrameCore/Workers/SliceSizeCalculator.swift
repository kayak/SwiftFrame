import Foundation

struct SliceSizeCalculator {

    static func calculateSliceSize(templateImageSize: CGSize, numberOfSlices: Int, gapWidth: Int?) throws -> CGSize {
        guard numberOfSlices > 0 else {
            throw NSError(description: "Number of slices must be larger than 0")
        }
        // number of slices minus 1 because gaps are only in between, multiplied by gapWidth
        let totalGapWidthIfAny = gapWidth.flatMap { (numberOfSlices - 1) * $0 }
        let templateWidthSubstractingGaps = templateImageSize.width - CGFloat(totalGapWidthIfAny ?? 0)

        guard Int(templateWidthSubstractingGaps) >= numberOfSlices else {
            let minimumTemplateWidth = numberOfSlices + (totalGapWidthIfAny ?? 0)
            throw NSError(
                description: "Template image is not wide enough to accommodate \(Pluralizer.pluralize(numberOfSlices, singular: "slice", plural: "slices"))",
                expectation: "Template image should be at least \(minimumTemplateWidth) pixels wide",
                actualValue: "Template image is \(templateImageSize.width) pixels wide"
            )
        }

        // Resulting slice is remaining width divided by expected number of slices, height can just be forwarded
        return CGSize(width: templateWidthSubstractingGaps / CGFloat(numberOfSlices), height: templateImageSize.height)
    }

}
