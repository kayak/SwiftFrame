import Foundation

struct SliceSizeCalculator {

    static func calculateSliceSize(templateImageSize: CGSize, numberOfSlices: Int, gapWidth: Int?) -> CGSize {
        // number of slices minus 1 because gaps are only in between, multiplied by gapWidth
        let totalGapWidthIfAny = gapWidth.flatMap { (numberOfSlices - 1) * $0 }
        let templateWidthSubstractingGaps = templateImageSize.width - CGFloat(totalGapWidthIfAny ?? 0)
        // Resulting slice is remaining width divided by expected number of slices, height can just be forwarded
        return CGSize(width: templateWidthSubstractingGaps / CGFloat(numberOfSlices), height: templateImageSize.height)
    }

}
