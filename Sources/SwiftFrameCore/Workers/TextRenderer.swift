import AppKit
import Foundation

final class TextRenderer {

    private let kMinFontSize: CGFloat = 1

    // MARK: - Frame Rendering

    func render(text: String, font: NSFont, color: NSColor, alignment: TextAlignment, rect: NSRect, context: CGContext) throws {
        let attributedString = try makeAttributedString(for: text, font: font, color: color, alignment: alignment)

        context.saveGState()
        defer { context.restoreGState() }

        let frame = makeFrame(from: attributedString, in: rect)
        CTFrameDraw(frame, context)
    }

    private func makeFrame(from attributedText: NSAttributedString, in rect: NSRect) -> CTFrame {
        let path = CGPath(rect: rect, transform: nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        return CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedText.length), path, nil)
    }

    // MARK: - Fitting & Size Computations

    /// Determines the maximum point size of the specified font that allows to render the given text onto a
    /// particular number of lines
    func maximumFontSizeThatFits(string: String, font: NSFont, alignment: TextAlignment, maxSize: CGFloat, size: CGSize) throws -> CGFloat {
        guard !string.isEmpty else {
            throw NSError(description: "Empty string was passed to TextRenderer")
        }

        let calculatedFontSize = try maxFontSizeThatFits(string: string, font: font, alignment: alignment, minSize: kMinFontSize, maxSize: maxSize, size: size)
        return min(calculatedFontSize.rounded(.down), maxSize)
    }

    private func maxFontSizeThatFits(string: String, font: NSFont, alignment: TextAlignment, minSize: CGFloat, maxSize: CGFloat, size: CGSize) throws -> CGFloat {
        let fontSize = (minSize + maxSize) / 2
        let adaptedFont = font.ky_toFont(ofSize: fontSize)

        // Need to use attributed strings since it may contain bold parts which are wider than their non-bold counterpart
        let attributedString = try makeAttributedString(for: string, font: adaptedFont, alignment: alignment)

        // if the search range is smaller than 1e-5 of a font size we stop
        // returning either side of min or max depending on the state
        guard abs(maxSize - minSize) > 1e-5 else {
            let maxSizeString = try makeAttributedString(for: string, font: adaptedFont.ky_toFont(ofSize: maxSize), alignment: alignment)
            if formattedString(maxSizeString, fitsIntoRect: size) {
                return maxSize
            }
            let smallSizeString = try makeAttributedString(for: string, font: adaptedFont.ky_toFont(ofSize: minSize), alignment: alignment)
            if formattedString(smallSizeString, fitsIntoRect: size) {
                return minSize
            }
            throw NSError(description: "Could not fit text \"\(attributedString.string)\" into rectangle of size \(size)")
        }

        if formattedString(attributedString, fitsIntoRect: size) {
            return try maxFontSizeThatFits(string: string, font: adaptedFont, alignment: alignment, minSize: fontSize, maxSize: maxSize, size: size)
        } else {
            return try maxFontSizeThatFits(string: string, font: adaptedFont, alignment: alignment, minSize: minSize, maxSize: fontSize, size: size)
        }
    }

    private func formattedString(_ attributedString: NSAttributedString, fitsIntoRect desiredSize: CGSize) -> Bool {
        let constraintSize = CGSize(width: desiredSize.width, height: CGFloat.greatestFiniteMagnitude)
        let stringSize = attributedString.boundingRect(with: constraintSize, options: [.usesLineFragmentOrigin, .usesFontLeading]).size

        return stringSize.width <= desiredSize.width && stringSize.height <= desiredSize.height
    }

    // MARK: - Misc

    private func makeAttributedString(for htmlString: String, font: NSFont, color: NSColor = .white, alignment: TextAlignment) throws -> NSAttributedString {
        let htmlString = makeHTMLFormattedString(for: htmlString, font: font, color: color)
        guard let stringData = htmlString.data(using: .utf8), let attributedString = NSMutableAttributedString.ky_makeFromData(stringData) else {
            throw NSError(description: "Could not make attributed string for string \"\(htmlString)\"")
        }
        attributedString.setAlignment(alignment.nsAlignment, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }

    private func makeHTMLFormattedString(for text: String, font: NSFont, color: NSColor) -> String {
        let colorHexString = color.usingColorSpace(.genericRGB)?.ky_hexString ?? color.ky_hexString

        let attributes = [
            "font-family: \(font.fontName)",
            "font-size: \(Int(font.pointSize))",
            "color: \(colorHexString)"
        ]

        let constructedAttributes = attributes.joined(separator: "; ")
        return String(format: "<span style=\"%@\">%@</span>", constructedAttributes, text)
    }

}

@propertyWrapper struct ThreadSafe<T> {

    private var _value: T
    private let queue: DispatchQueue

    init(initialValue: T, queue: DispatchQueue) {
        self._value = initialValue
        self.queue = queue
    }

    var wrappedValue: T {
        get {
            queue.sync { _value }
        }
        set {
            queue.sync { _value = newValue }
        }
    }

}
