import AppKit
import Foundation

final class TextRenderer {

    // MARK: - Fitting & Size Computations

    private enum FontSizeState {
        case fit, tooBig, tooSmall
    }

    private func binarySearch(string: String, minSize: CGFloat, maxSize: CGFloat, size: CGSize, constraintSize: CGSize, font: NSFont) -> CGFloat {
        let fontSize = (minSize + maxSize) / 2
        var attributes = makeAttributes(font: font)
        attributes[NSAttributedString.Key.font] = font.toFont(ofSize: fontSize)

        let rect = string.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        let state = multiLineSizeState(rect: rect, size: size)

        // if the search range is smaller than 0.1 of a font size we stop
        // returning either side of min or max depending on the state
        let diff = maxSize - minSize
        guard diff > 0.1 else {
            switch state {
            case .tooSmall:
                return maxSize
            default:
                return minSize
            }
        }

        switch state {
        case .fit: return fontSize
        case .tooBig: return binarySearch(string: string, minSize: minSize, maxSize: fontSize, size: size, constraintSize: constraintSize, font: font)
        case .tooSmall: return binarySearch(string: string, minSize: fontSize, maxSize: maxSize, size: size, constraintSize: constraintSize, font: font)
        }
    }

    private func singleLineSizeState(rect: CGRect, size: CGSize) -> FontSizeState {
        if rect.width >= size.width + 10 && rect.width <= size.width {
            return .fit
        } else if rect.width > size.width {
            return .tooBig
        } else {
            return .tooSmall
        }
    }

    private func multiLineSizeState(rect: CGRect, size: CGSize) -> FontSizeState {
        // if rect within 10 of size
        if rect.height < size.height + 10 &&
            rect.height > size.height - 10 &&
            rect.width > size.width + 10 &&
            rect.width < size.width - 10 {
            return .fit
        } else if rect.height > size.height || rect.width > size.width {
            return .tooBig
        } else {
            return .tooSmall
        }
    }

    /// Determines the maximum point size of the specified font that allows to render the given text onto a
    /// particular number of lines
    func maximumFontSizeThatFits(string: String, maxFontSize: CGFloat = 100, minFontScale: CGFloat = 0.1, size: CGSize, font: NSFont) throws -> CGFloat {
        let maxFontSize = maxFontSize.isNaN ? 100 : maxFontSize
        let minFontScale = minFontScale.isNaN ? 0.1 : minFontScale
        let minimumFontSize = maxFontSize * minFontScale
        guard !string.isEmpty else {
            return maxFontSize
        }

        let constraintSize = CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude)
        let calculatedFontSize = binarySearch(string: string, minSize: minimumFontSize, maxSize: maxFontSize, size: size, constraintSize: constraintSize, font: font)
        return (calculatedFontSize * 10.0).rounded(.down) / 10.0
    }

    private func numberOfLines(text: String, font: NSFont, rect: CGRect, isSmallerOrEqualTo maximum: Int) -> Bool {
        let attributes = makeAttributes(font: font)
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let originRect = NSRect(origin: .zero, size: rect.size)
        let frame = makeFrame(from: attributedText, in: originRect)
        let numberOfLines = CFArrayGetCount(CTFrameGetLines(frame))
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
