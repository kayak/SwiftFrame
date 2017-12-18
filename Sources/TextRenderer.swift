import AppKit
import Foundation

final class TextRenderer {

    // MARK: - Fitting & Size Computations

    /// Determines the maximum point size of the specified font that allows to render all of the given texts
    /// onto a particular number of lines
    func maximumFontSizeThatFits(
        texts: [String],
        font: NSFont,
        lines: Int,
        width: CGFloat,
        lowerBound: CGFloat = 1,
        upperBound: CGFloat) throws -> CGFloat
    {
        guard !texts.isEmpty else {
            throw NSError(description: "Cannot determine common maximum font size without texts")
        }
        var commonMaximum = CGFloat.greatestFiniteMagnitude
        for text in texts {
            let maximum = try maximumFontSizeThatFits(
                text: text,
                font: font,
                lines: lines,
                width: width,
                lowerBound: lowerBound,
                upperBound: upperBound)
            if maximum < commonMaximum {
                commonMaximum = maximum
            }
        }
        return commonMaximum
    }

    /// Determines the maximum point size of the specified font that allows to render the given text onto a
    /// particular number of lines
    func maximumFontSizeThatFits(
        text: String,
        font: NSFont,
        lines: Int,
        width: CGFloat,
        lowerBound: CGFloat = 1,
        upperBound: CGFloat) throws -> CGFloat
    {
        if fabs(upperBound - lowerBound) < 1e-5 {
            if numberOfLines(text: text, font: font.toFont(ofSize: upperBound), width: width, isSmallerOrEqualTo: lines) {
                return upperBound
            }
            if numberOfLines(text: text, font: font.toFont(ofSize: lowerBound), width: width, isSmallerOrEqualTo: lines) {
                return lowerBound
            }
            throw NSError(description: "Could not fit \"\(text)\" onto \(lines) lines")
        }
        let size = (lowerBound + upperBound) / 2.0
        if numberOfLines(text: text, font: font.toFont(ofSize: size), width: width, isSmallerOrEqualTo: lines) {
            return try maximumFontSizeThatFits(text: text, font: font, lines: lines, width: width, lowerBound: size, upperBound: upperBound)
        } else {
            return try maximumFontSizeThatFits(text: text, font: font, lines: lines, width: width, lowerBound: lowerBound, upperBound: size)
        }
    }

    private func numberOfLines(text: String, font: NSFont, width: CGFloat, isSmallerOrEqualTo maximum: Int) -> Bool {
        let attributes = makeAttributes(font: font)
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let rect = NSRect(x: 0, y: 0, width: width, height: attributedText.size().height * CGFloat(maximum + 3)) // Make sure to have enough vertical space
        let frame = makeFrame(from: attributedText, in: rect)
        return CFArrayGetCount(CTFrameGetLines(frame)) <= maximum
    }

    func suggestHeightForRendering(text: String, font: NSFont, width: CGFloat) -> CGFloat {
        let attributes = makeAttributes(font: font)
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        let size = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange(location: 0, length: 0), nil,
            CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), nil)
        return size.height
    }

    func minimumWidthThatFits(
        text: String,
        font: NSFont,
        lines: Int,
        lowerBound: CGFloat = 0,
        upperBound: CGFloat) throws -> CGFloat
    {
        if fabs(upperBound - lowerBound) < 1e-5 {
            if numberOfLines(text: text, font: font, width: upperBound, isSmallerOrEqualTo: lines) {
                return upperBound
            }
            if numberOfLines(text: text, font: font, width: lowerBound, isSmallerOrEqualTo: lines) {
                return lowerBound
            }
            throw NSError(description: "Could not fit \"\(text)\" onto \(lines) lines")
        }
        let width = (lowerBound + upperBound) / 2.0
        if numberOfLines(text: text, font: font, width: width, isSmallerOrEqualTo: lines) {
            return try minimumWidthThatFits(text: text, font: font, lines: lines, lowerBound: lowerBound, upperBound: width)
        } else {
            return try minimumWidthThatFits(text: text, font: font, lines: lines, lowerBound: width, upperBound: upperBound)
        }
    }

    // MARK: - Frame Rendering

    func render(text: String, font: NSFont, color: NSColor, alignment: NSTextAlignment, rect: NSRect, context: CGContext) {
        let attributes = makeAttributes(font: font, color: color, alignment: alignment)
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let frame = makeFrame(from: attributedText, in: rect)
        CTFrameDraw(frame, context)
    }

    private func makeFrame(from attributedText: NSAttributedString, in rect: NSRect) -> CTFrame {
        let path = CGPath(rect: rect, transform: nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        return CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedText.length), path, nil)
    }

    // MARK: - Misc

    private func makeAttributes(font: NSFont, color: NSColor? = nil, alignment: NSTextAlignment? = nil) -> [NSAttributedStringKey: Any] {
        var attributes: [NSAttributedStringKey: Any] = [.font: font]
        if let color = color {
            attributes[.foregroundColor] = color
        }
        if let alignment = alignment {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = alignment
            attributes[.paragraphStyle] = paragraphStyle
        }
        return attributes
    }

}
