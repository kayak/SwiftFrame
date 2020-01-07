import AppKit
import Foundation

final class TextRenderer {

    // MARK: - Fitting & Size Computations

    private enum FontSizeState {
        case fit, tooBig, tooSmall
    }

    /// Determines the maximum point size of the specified font that allows to render the given text onto a
    /// particular number of lines
    func maximumFontSizeThatFits(string: String, size: CGSize, font: NSFont, maxFontSize: CGFloat, minFontSize: CGFloat = 1) throws -> CGFloat {
        guard !string.isEmpty else {
            throw NSError(description: "Empyt string was passed to TextRenderer")
        }

        let constraintSize = CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude)
        let calculatedFontSize = maxFontSizeThatFits(string: string, minSize: minFontSize, maxSize: maxFontSize, size: size, constraintSize: constraintSize, font: font)
        return calculatedFontSize.rounded(.down)
    }

    private func maxFontSizeThatFits(string: String, minSize: CGFloat, maxSize: CGFloat, size: CGSize, constraintSize: CGSize, font: NSFont) -> CGFloat {
        let fontSize = (minSize + maxSize) / 2
        let attributes = makeAttributes(font: font.toFont(ofSize: fontSize))

        let stringRect = string.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        let state = multiLineSizeState(stringSize: stringRect.size, desiredSize: size)

        // if the search range is smaller than 0.1 of a font size we stop
        // returning either side of min or max depending on the state
        guard abs(maxSize - minSize) > 1e-5 else {
            switch state {
            case .tooSmall:
                return maxSize
            default:
                return minSize
            }
        }

        switch state {
        case .fit:
            return fontSize
        case .tooBig:
            return maxFontSizeThatFits(string: string, minSize: minSize, maxSize: fontSize, size: size, constraintSize: constraintSize, font: font)
        case .tooSmall:
            return maxFontSizeThatFits(string: string, minSize: fontSize, maxSize: maxSize, size: size, constraintSize: constraintSize, font: font)
        }
    }

    private func multiLineSizeState(stringSize: CGSize, desiredSize: CGSize) -> FontSizeState {
        // if rect is within two percent of size, consider text to fit
        if stringSize.isWithin(desiredSize, tolerancePercent: 2) {
            return .fit
        } else if stringSize.height > desiredSize.height || stringSize.width > desiredSize.width {
            return .tooBig
        } else {
            return .tooSmall
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

extension CGSize {
    func isWithin(_ otherSize: CGSize, tolerancePercent: Int) -> Bool {
        guard percent >= -100 else {
            return false
        }

        let fraction = CGFloat(percent + 100) / 100.00
        return otherSize.height < height * fraction
            && otherSize.height * fraction < height
            && otherSize.width < width * fraction
            && otherSize.width * fraction < width
    }
}
