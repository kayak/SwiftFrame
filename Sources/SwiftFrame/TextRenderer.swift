import AppKit
import Foundation

private let kMinFontSize: CGFloat = 4

final class TextRenderer {

    private enum FontSizeState {
        case fit, tooBig, tooSmall
    }

    // MARK: - Frame Rendering

    func render(text: String, font: NSFont, color: NSColor, alignment: NSTextAlignment, rect: NSRect, context: CGContext) throws {
        guard let attributedString = makeAttributedString(for: text, font: font, color: color, alignment: alignment) else {
            throw NSError(description: "Could not make attributed string")
        }

        let frame = makeFrame(from: attributedString, in: rect)
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

    // MARK: - Fitting & Size Computations

    /// Determines the maximum point size of the specified font that allows to render the given text onto a
    /// particular number of lines
    func maximumFontSizeThatFits(string: String, size: CGSize, font: NSFont, maxFontSize: CGFloat) throws -> CGFloat {
        guard !string.isEmpty else {
            throw NSError(description: "Empty string was passed to TextRenderer")
        }

        let calculatedFontSize = try maxFontSizeThatFits(string: string, font: font, alignment: .center, minSize: kMinFontSize, maxSize: maxFontSize, size: size)

        // Subtract 0.5 to avoid floating point precision issues
        return calculatedFontSize.rounded(.down) - 0.5
    }

    private func maxFontSizeThatFits(string: String, font: NSFont, alignment: NSTextAlignment, minSize: CGFloat, maxSize: CGFloat, size: CGSize) throws -> CGFloat {
        let fontSize = (minSize + maxSize) / 2
        let adaptedFont = font.toFont(ofSize: fontSize)

        // Need to use attributed strings since it may contain bold parts which are wider than their non-bold counterpart
        guard let attributedString = makeAttributedString(for: string, font: adaptedFont, color: .red, alignment: alignment) else {
            throw NSError(description: "Could not make attributed string")
        }

        let constraintSize = CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude)
        let stringRect = attributedString.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin)
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
            return try maxFontSizeThatFits(string: string, font: font, alignment: alignment, minSize: minSize, maxSize: fontSize, size: size)
        case .tooSmall:
            return try maxFontSizeThatFits(string: string, font: font, alignment: alignment, minSize: fontSize, maxSize: maxSize, size: size)
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

    // MARK: - Misc

    private func makeAttributedString(for htmlString: String, font: NSFont, color: NSColor, alignment: NSTextAlignment? = nil) -> NSAttributedString? {
        let htmlString = makeHTMLFormattedString(for: htmlString, font: font, color: color)
        guard let stringData = htmlString.data(using: .utf8), let attributedString = NSMutableAttributedString(html: stringData, documentAttributes: nil) else {
            return nil
        }

        if let alignment = alignment {
            attributedString.setAlignment(alignment, range: NSRange(location: 0, length: attributedString.length))
        }
        return attributedString
    }

    private func makeHTMLFormattedString(for text: String, font: NSFont, color: NSColor) -> String {
        let attributes = [
            "font-family: \(font.fontName)",
            "font-size: \(Int(font.pointSize))",
            "color: \(color.hexString)",
        ]

        let constructedAttributes = attributes.joined(separator: "; ")
        return String(format: "<span style=\"%@\">%@</span>", constructedAttributes, text)
    }

}

extension NSTextAlignment {
    var cssName: String {
        switch self {
        case .left:
            return "left"
        case .right:
            return "right"
        case .center:
            return "center"
        case .justified:
            return "justify"
        default:
            return "inherit"
        }
    }
}

extension CGSize {
    func isWithin(_ otherSize: CGSize, tolerancePercent percent: Int) -> Bool {
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
