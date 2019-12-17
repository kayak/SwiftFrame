import AppKit
import Foundation

struct Point: Codable {
    let x: Int
    let y: Int

    var formattedString: String {
        "(\(x), \(y))"
    }

    var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}
