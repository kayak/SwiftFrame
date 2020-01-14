import AppKit
import Foundation

private let kMinFontSize: CGFloat = 1

public final class TextRenderer {

    // MARK: - Frame Rendering

    func render(text: String, font: NSFont, color: NSColor, alignment: NSTextAlignment, rect: NSRect, context: CGContext) throws {
        let attributedString = try makeAttributedString(for: text, font: font, color: color, alignment: alignment)

        context.saveGState()
        defer { context.restoreGState() }

        let frame = makeFrame(from: attributedString, in: rect)
        CTFrameDraw(frame, context)

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
    func maximumFontSizeThatFits(string: String, font: NSFont, alignment: NSTextAlignment, maxSize: CGFloat, size: CGSize) throws -> CGFloat {
        guard !string.isEmpty else {
            throw NSError(description: "Empty string was passed to TextRenderer")
        }

        let calculatedFontSize = try maxFontSizeThatFits(string: string, font: font, alignment: alignment, minSize: kMinFontSize, maxSize: maxSize, size: size)
        return min(calculatedFontSize.rounded(.down), maxSize)
    }

    private func maxFontSizeThatFits(string: String, font: NSFont, alignment: NSTextAlignment, minSize: CGFloat, maxSize: CGFloat, size: CGSize) throws -> CGFloat {
        let fontSize = (minSize + maxSize) / 2
        let adaptedFont = font.toFont(ofSize: fontSize)

        // Need to use attributed strings since it may contain bold parts which are wider than their non-bold counterpart
        let attributedString = try makeAttributedString(for: string, font: adaptedFont, alignment: alignment)

        // if the search range is smaller than 1e-5 of a font size we stop
        // returning either side of min or max depending on the state
        guard abs(maxSize - minSize) > 1e-5 else {
            let maxSizeString = try makeAttributedString(for: string, font: adaptedFont.toFont(ofSize: maxSize), alignment: alignment)
            if formattedString(maxSizeString, fitsIntoRect: size) {
                return maxSize
            }
            let smallSizeString = try makeAttributedString(for: string, font: adaptedFont.toFont(ofSize: minSize), alignment: alignment)
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
        let stringSize = attributedString.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin).size

        return stringSize.width <= desiredSize.width && stringSize.height <= desiredSize.height
    }

    // MARK: - Misc

    private func makeAttributedString(for htmlString: String, font: NSFont, color: NSColor = .white, alignment: NSTextAlignment) throws -> NSAttributedString {
        let htmlString = makeHTMLFormattedString(for: htmlString, font: font, color: color)
        guard let stringData = htmlString.data(using: .utf8), let attributedString = NSMutableAttributedString(html: stringData, documentAttributes: nil) else {
            throw NSError(description: "Could not make attributed string for string \"\(htmlString)\"")
        }
        attributedString.setAlignment(alignment, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }

    private func makeHTMLFormattedString(for text: String, font: NSFont, color: NSColor) -> String {
        let colorHexString = color.usingColorSpace(.genericRGB)?.hexString ?? color.hexString

        let attributes = [
            "font-family: \(font.fontName)",
            "font-size: \(Int(font.pointSize))",
            "color: \(colorHexString)",
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

extension Int {
    var percentFraction: CGFloat {
        return CGFloat(self) / 100.00
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
