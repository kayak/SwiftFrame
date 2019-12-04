import AppKit
import Foundation

private let gradientRegex = try! NSRegularExpression(pattern: "^linear-gradient\\(\\s*([^,]+)\\s*,\\s*([^\\)]+)\\s*\\)$", options: [])

enum Background: CustomStringConvertible {

    case solid(NSColor)
    case linearGradient(GradientDirection, [NSColor])

    // MARK: - Object Lifecycle

    init(specification: String) throws {
        if specification.hasPrefix("#") {
            self = .solid(try NSColor(hexString: specification))
            return
        }
        if let match = gradientRegex.firstMatch(in: specification, options: [], range: NSRange(location: 0, length: (specification as NSString).length)) {
            guard
                match.numberOfRanges == 3,
                let direction = GradientDirection(value: match.substring(forRangeAt: 1, in: specification))
            else {
                throw NSError(description: "Failed to parse linear gradient background specification \(specification)")
            }
            let colors = try match.substring(forRangeAt: 2, in: specification).components(separatedBy: ",").map {
                try NSColor(hexString: $0.trimmingCharacters(in: .whitespaces))
            }
            guard colors.count >= 2 else {
                throw NSError(description: "Failed to parse linear gradient background specification \(specification)")
            }
            self = .linearGradient(direction, colors)
            return
        }
        throw NSError(description: "Failed to parse background specification \(specification)")
    }

    // MARK: - Misc

    var description: String {
        switch self {
        case .solid(let color):
            return color.hexString
        case .linearGradient(let direction, let colors):
            return "linear-gradient(\(direction), \(colors.map({ $0.hexString }).joined(separator: ", ")))"
        }
    }

    // MARK: - Gradient Direction

    enum GradientDirection: CustomStringConvertible {
        case toTop
        case toBottom
        case toLeft
        case toRight

        case toLeftTop
        case toRightTop
        case toLeftBottom
        case toRightBottom

        // MARK: - Object Lifecycle

        init?(value: String) {
            switch value {
            case "to top":
                self = .toTop
            case "to bottom":
                self = .toBottom
            case "to left":
                self = .toLeft
            case "to right":
                self = .toRight
            case "to left top":
                self = .toLeftTop
            case "to right top":
                self = .toRightTop
            case "to left bottom":
                self = .toLeftBottom
            case "to right bottom":
                self = .toRightBottom
            default:
                return nil
            }
        }

        // MARK: - Start & End Point

        /// X component of gradient start point in CG's coordinate system for a unit square
        var relativeStartX: CGFloat {
            switch self {
            case .toTop:
                return 0
            case .toBottom:
                return 0
            case .toLeft:
                return 1
            case .toRight:
                return 0
            case .toLeftTop:
                return 1
            case .toRightTop:
                return 0
            case .toLeftBottom:
                return 1
            case .toRightBottom:
                return 0
            }
        }

        /// Y component of gradient start point in CG's coordinate system for a unit square
        var relativeStartY: CGFloat {
            switch self {
            case .toTop:
                return 0
            case .toBottom:
                return 1
            case .toLeft:
                return 0
            case .toRight:
                return 0
            case .toLeftTop:
                return 0
            case .toRightTop:
                return 0
            case .toLeftBottom:
                return 1
            case .toRightBottom:
                return 1
            }
        }

        /// X component of gradient end point in CG's coordinate system for a unit square
        var relativeEndX: CGFloat {
            switch self {
            case .toTop:
                return 0
            case .toBottom:
                return 0
            case .toLeft:
                return 0
            case .toRight:
                return 1
            case .toLeftTop:
                return 0
            case .toRightTop:
                return 1
            case .toLeftBottom:
                return 0
            case .toRightBottom:
                return 1
            }
        }

        /// Y component of gradient end point in CG's coordinate system for a unit square
        var relativeEndY: CGFloat {
            switch self {
            case .toTop:
                return 1
            case .toBottom:
                return 0
            case .toLeft:
                return 0
            case .toRight:
                return 0
            case .toLeftTop:
                return 1
            case .toRightTop:
                return 1
            case .toLeftBottom:
                return 0
            case .toRightBottom:
                return 0
            }
        }

        // MARK: - Misc

        var description: String {
            switch self {
            case .toTop:
                return "to top"
            case .toBottom:
                return "to bottom"
            case .toLeft:
                return "to left"
            case .toRight:
                return "to right"
            case .toLeftTop:
                return "to left top"
            case .toRightTop:
                return "to right top"
            case .toLeftBottom:
                return "to left bottom"
            case .toRightBottom:
                return "to right bottom"
            }
        }
    }

}
