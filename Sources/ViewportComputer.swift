import AppKit
import Foundation

protocol ViewportComputerProtocol {

    func computeViewportRect(from frame: NSImage, hasNotch: Bool) -> NSRect?
    func computeViewportMask(from frame: NSImage, with viewport: NSRect) throws -> NSImage?

}

class ViewportComputer: ViewportComputerProtocol {

    // MARK: - Viewport Computation

    func computeViewportRect(from frame: NSImage, hasNotch: Bool) -> NSRect? {
        return computeLLOViewportRect(from: frame, hasNotch: hasNotch)
    }

    /// Computes the viewport of the supplied frame image. The viewport is returned as an `NSRect` in a coordinate system with
    /// the origin in the upper left corner (AppKit's default).
    private func computeULOViewportRect(from frame: NSImage, hasNotch: Bool) -> NSRect? {
        let cgImage = frame.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let representation = NSBitmapImageRep(cgImage: cgImage)
        let center = Point(x: Int(frame.size.width / 2), y: Int(frame.size.height / 2))
        let centerColor = representation.color(at: center)
        let x1 = find(.start, of: centerColor, along: .x, startingAt: center, in: representation)
        let x2 = find(.end, of: centerColor, along: .x, startingAt: center, in: representation)
        let minX = hasNotch ? x1 : nil
        let maxX = hasNotch ? x2 : nil
        let y1 = find(.start, of: centerColor, along: .y, startingAt: center, minOnInvertedAxis: minX, maxOnInvertedAxis: maxX, in: representation)
        let y2 = find(.end, of: centerColor, along: .y, startingAt: center, minOnInvertedAxis: minX, maxOnInvertedAxis: maxX, in: representation)
        return x1 == x2 || y1 == y2 ? nil : NSRect(x: x1, y: y1, width: x2 - x1 + 1, height: y2 - y1 + 1)
    }

    /// Computes the viewport of the supplied frame image. The viewport is returned as an `NSRect` in a coordinate system with
    /// the origin in the lower left corner (Core Graphic's default).
    private func computeLLOViewportRect(from frame: NSImage, hasNotch: Bool) -> NSRect? {
        guard let uloViewport = computeULOViewportRect(from: frame, hasNotch: hasNotch) else {
            return nil
        }
        return NSRect(
            x: uloViewport.origin.x,
            y: frame.size.height - uloViewport.origin.y - uloViewport.size.height,
            width: uloViewport.size.width,
            height: uloViewport.size.height)
    }

    // MARK: - Viewport Mask Computation

    func computeViewportMask(from frame: NSImage, with viewport: NSRect) throws -> NSImage? {
        var rect = NSRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        let cgImage = frame.cgImage(forProposedRect: &rect, context: nil, hints: nil)!
        let strideLength = ((cgImage.width + 4 - 1) / 4) * 4
        var pixelData = [UInt8](repeating: 0, count: strideLength * cgImage.height)

        guard let context = CGContext(
            data: &pixelData,
            width: cgImage.width,
            height: cgImage.height,
            bitsPerComponent: 8,
            bytesPerRow: strideLength,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue)
        else {
            throw NSError(description: "Failed to create graphics context")
        }

        context.draw(cgImage, in: rect)

        guard pixelData[cgImage.height / 2 * strideLength + cgImage.width / 2] == 0 else {
            return nil // Abort if viewport is not transparent
        }

        for i in 0 ..< pixelData.count {
            pixelData[i] = pixelData[i] > 0 ? 0 : 255
        }

        guard let maskImage = context.makeImage() else {
            throw NSError(description: "Failed to extract image from graphics context")
        }

        return NSImage(cgImage: maskImage.cropping(to: viewport)!, size: frame.size)
    }

}

// MARK: - Misc

private enum Axis {
    case x, y

    var inverted: Axis {
        switch self {
        case .x:
            return .y
        case .y:
            return .x
        }
    }
}

private enum Target {
    case start, end

    func maximizingCoordinate(_ coordinate1: Int, _ coordinate2: Int) -> Int {
        switch self {
        case .start:
            return coordinate1 < coordinate2 ? coordinate1 : coordinate2
        case .end:
            return coordinate1 > coordinate2 ? coordinate1 : coordinate2
        }
    }
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

private func find(
    _ target: Target,
    of color: NSColor?,
    along axis: Axis,
    startingAt point: Point,
    minOnInvertedAxis: Int? = nil,
    maxOnInvertedAxis: Int? = nil,
    in representation: NSBitmapImageRep) -> Int
{
    var result = point.coordinate(along: axis)
    for i in (minOnInvertedAxis ?? point.coordinate(along: axis.inverted)) ... (maxOnInvertedAxis ?? point.coordinate(along: axis.inverted)) {
        let start = point.translated(to: i, along: axis.inverted)
        for j in representation.makeStride(for: target, along: axis, startingAt: start) {
            if representation.color(at: start.translated(to: j, along: axis)) != color {
                break
            }
            result = target.maximizingCoordinate(j, result)
        }
    }
    return result
}
