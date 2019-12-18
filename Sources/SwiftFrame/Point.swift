import AppKit
import Foundation

struct Point: Codable {
    let x: Int
    let y: Int

    var formattedString: String {
        "(\(x), \(y))"
    }

    var ciVector: CIVector {
        CIVector(x: CGFloat(x), y: CGFloat(y))
    }
}
