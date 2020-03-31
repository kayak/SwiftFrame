import AppKit
import Foundation

// MARK: - CGSize

extension CGSize {

    static let square100Pixels: CGSize = CGSize(width: 100, height: 100)

    static func make100PixelsSize(with gapWidth: Int, numberOfGaps: Int) -> CGSize {
        CGSize(width: 100 + CGFloat(gapWidth * numberOfGaps), height: 100)
    }

}

// MARK: - Dictionary

extension Dictionary where Value == String, Key == String {

    func makeStringFileContent() -> String {
        let strings: [String] = keys.sorted().compactMap {
            guard let element = self[$0] else {
                return nil
            }
            return [$0, element + ";"].joined(separator: " = ")
        }
        return strings.joined(separator: "\n")
    }

}

// MARK: - CGContext

extension CGContext {

    static func with(size: CGSize) -> CGContext {
        CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    }

    static func makeImageRepWithSize(_ size: CGSize) -> NSBitmapImageRep {
        let context = CGContext.with(size: size)
        context.setFillColor(.white)
        context.fill(NSRect(x: 0, y: 0, width: size.width, height: size.height))
        return NSBitmapImageRep(cgImage: context.makeImage()!)
    }

}

/// Since `XCTUnwrap` is currently unavailable when calling `swift test` from the command line, we use a custom wrapper
/// See https://bugs.swift.org/browse/SR-11501
func ky_unwrap<T>(_ value: T?) throws -> T {
    guard let value = value else {
        throw NSError(description: "Value of type \(T.self) was nil")
    }
    return value
}
