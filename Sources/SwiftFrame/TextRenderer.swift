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
            throw NSError(description: "Empty string was passed to TextRenderer")
        }

        // Use non-grayscale color to avoid colorspace crash
        guard var attributedString = makeAttributedString(for: string, font: font, color: .red, alignment: nil) else {
            throw NSError(description: "Could not make attributed string")
        }

        let constraintSize = CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude)
        let calculatedFontSize = maxFontSizeThatFits(attributedString: &attributedString, minSize: minFontSize, maxSize: maxFontSize, size: size, constraintSize: constraintSize)
        return calculatedFontSize.rounded(.down)
    }

    private func maxFontSizeThatFits(attributedString: inout NSAttributedString, minSize: CGFloat, maxSize: CGFloat, size: CGSize, constraintSize: CGSize) -> CGFloat {
        let fontSize = (minSize + maxSize) / 2
        var attributes = attributedString.attributes(at: 0, effectiveRange: nil)
        let font = attributes[.font] as! NSFont
        attributes[.font] = font.toFont(ofSize: fontSize)

        let stringRect = attributedString.string.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
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
            return maxFontSizeThatFits(attributedString: &attributedString, minSize: minSize, maxSize: fontSize, size: size, constraintSize: constraintSize)
        case .tooSmall:
            return maxFontSizeThatFits(attributedString: &attributedString, minSize: fontSize, maxSize: maxSize, size: size, constraintSize: constraintSize)
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

    func render(text: String, font: NSFont, color: NSColor, alignment: NSTextAlignment, rect: NSRect, context: CGContext) throws {
        guard let attributedString = makeAttributedString(for: text, font: font, color: color, alignment: alignment) else {
            throw NSError(description: "Could not make attributed string")
        }

        let frame = makeFrame(from: attributedString, in: rect)
        CTFrameDraw(frame, context)
    }

    private func makeFrame(from attributedText: NSAttributedString, in rect: NSRect) -> CTFrame {
        let path = CGPath(rect: rect, transform: nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        return CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedText.length), path, nil)
    }

    // MARK: - Misc

    private func makeAttributedString(for htmlString: String, font: NSFont, color: NSColor, alignment: NSTextAlignment?) -> NSAttributedString? {
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
