import AppKit
import Foundation

protocol ViewportComputerProtocol {
    func compute(from image: NSImage) -> NSRect?
}

class ViewportComputer: ViewportComputerProtocol {

    func compute(from image: NSImage) -> NSRect? {
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let representation = NSBitmapImageRep(cgImage: cgImage)
        let center = Point(x: Int(image.size.width / 2), y: Int(image.size.height / 2))
        let centerColor = representation.color(at: center)
        let x1 = find(.start, of: centerColor, along: .x, startingAt: center, in: representation)
        let x2 = find(.end, of: centerColor, along: .x, startingAt: center, in: representation)
        let y1 = find(.start, of: centerColor, along: .y, startingAt: center, in: representation)
        let y2 = find(.end, of: centerColor, along: .y, startingAt: center, in: representation)
        return x1 == x2 || y1 == y2 ? nil : NSRect(x: x1, y: y1, width: x2 - x1 + 1, height: y2 - y1 + 1)
    }

}

private enum Axis {
    case x, y
}

private enum Target {
    case start, end
}

private struct Point {
    let x: Int
    let y: Int

    func translated(to coordinate: Int, along axis: Axis) -> Point {
        return axis == .x ? Point(x: coordinate, y: y) : Point(x: x, y: coordinate)
    }

    func coordinate(along axis: Axis) -> Int {
        return axis == .x ? x : y
    }
}

private extension NSBitmapImageRep {
    func makeStride(for target: Target, along axis: Axis, startingAt origin: Point) -> StrideThrough<Int> {
        switch target {
        case .start:
            return stride(from: origin.coordinate(along: axis), through: 0, by: -1)
        case .end:
            return stride(from: origin.coordinate(along: axis), through: axis == .x ? pixelsWide - 1 : pixelsHigh - 1, by: 1)
        }
    }

    func color(at point: Point) -> NSColor? {
        return colorAt(x: point.x, y: point.y)
    }
}

private func find(_ target: Target, of color: NSColor?, along axis: Axis, startingAt point: Point, in representation: NSBitmapImageRep) -> Int {
    var result = point.coordinate(along: axis)
    for i in representation.makeStride(for: target, along: axis, startingAt: point) {
        if representation.color(at: point.translated(to: i, along: axis)) != color {
            break
        }
        result = i
    }
    return result
}
