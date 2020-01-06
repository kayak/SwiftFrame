import AppKit
import Foundation

final class TextRenderer {

    // MARK: - Fitting & Size Computations

    /// Determines the maximum point size of the specified font that allows to render all of the given texts
    /// onto a particular number of lines
//    func maximumFontSizeThatFits(
//        texts: [String],
//        font: NSFont,
//        lines: Int,
//        rect: CGRect,
//        lowerBound: CGFloat = 1,
//        upperBound: CGFloat) throws -> CGFloat
//    {
//        guard !texts.isEmpty else {
//            throw NSError(description: "Cannot determine common maximum font size without texts")
//        }
//        var commonMaximum = CGFloat.greatestFiniteMagnitude
//        for text in texts {
//            let maximum = try maximumFontSizeThatFits(
//                text: text,
//                font: font,
//                lines: lines,
//                rect: rect,
//                lowerBound: lowerBound,
//                upperBound: upperBound)
//            if maximum < commonMaximum {
//                commonMaximum = maximum
//            }
//        }
//        return commonMaximum
//    }

    /// Determines the maximum point size of the specified font that allows to render the given text onto a
    /// particular number of lines
    func maximumFontSizeThatFits(
        text: String,
        font: NSFont,
        lines: Int,
        rect: CGRect,
        lowerBound: CGFloat = 1,
        upperBound: CGFloat) throws -> CGFloat
    {
        if abs(upperBound - lowerBound) < 1e-5 {
            if numberOfLines(text: text, font: font.toFont(ofSize: upperBound), rect: rect, isSmallerOrEqualTo: lines) {
                return upperBound
            }
            if numberOfLines(text: text, font: font.toFont(ofSize: lowerBound), rect: rect, isSmallerOrEqualTo: lines) {
                return lowerBound
            }
            throw NSError(description: "Could not fit \"\(text)\" onto \(lines) lines")
        }
        let size = (lowerBound + upperBound) / 2.0
        print("trying size", size)
        if numberOfLines(text: text, font: font.toFont(ofSize: size), rect: rect, isSmallerOrEqualTo: lines) {
            return try maximumFontSizeThatFits(text: text, font: font, lines: lines, rect: rect, lowerBound: size, upperBound: upperBound)
        } else {
            return try maximumFontSizeThatFits(text: text, font: font, lines: lines, rect: rect, lowerBound: lowerBound, upperBound: size)
        }
    }

    private func numberOfLines(text: String, font: NSFont, rect: CGRect, isSmallerOrEqualTo maximum: Int) -> Bool {
        let attributes = makeAttributes(font: font)
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let originRect = NSRect(origin: .zero, size: rect.size)
        let frame = makeFrame(from: attributedText, in: originRect)
        let numberOfLines = CFArrayGetCount(CTFrameGetLines(frame))
        print(numberOfLines)
        return numberOfLines <= maximum
    }

    // MARK: - Frame Rendering

    func render(text: String, font: NSFont, color: NSColor, alignment: NSTextAlignment, rect: NSRect, context: CGContext) {
        let attributes = makeAttributes(font: font, color: color, alignment: alignment)
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let frame = makeFrame(from: attributedText, in: rect)
        CTFrameDraw(frame, context)

        // DEBUG

        context.addRect(rect)
        context.drawPath(using: .stroke)
    }

    private func makeFrame(from attributedText: NSAttributedString, in rect: NSRect) -> CTFrame {
        let path = CGPath(rect: rect, transform: nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        return CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedText.length), path, nil)
    }

    // MARK: - Misc

    private func makeAttributes(font: NSFont, color: NSColor? = nil, alignment: NSTextAlignment? = nil) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [.font: font]
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
