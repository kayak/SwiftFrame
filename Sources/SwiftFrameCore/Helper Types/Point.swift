import AppKit
import Foundation

struct Point: Codable, Equatable {

    // MARK: - Properties

    let x: Int
    let y: Int

    var ciVector: CIVector {
        CIVector(x: CGFloat(x), y: CGFloat(y))
    }

    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }

    // MARK: - Coordinate space conversion

    public func convertingToBottomLeftOrigin(with size: CGSize) -> Point {
        let newY = Int(size.height) - y
        return Point(x: x, y: newY)
    }

}
