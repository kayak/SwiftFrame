import AppKit
import Foundation

struct Point: Codable, Equatable {

    // MARK: - Properties

    let x: Int
    let y: Int

    var ciVector: CIVector {
        CIVector(x: CGFloat(x), y: CGFloat(y))
    }

    // MARK: - Coordinate space conversion

    func convertingToBottomLeftOrigin(withSize size: CGSize) -> Point {
        let newY = Int(size.height) - y
        return Point(x: x, y: newY)
    }

}
