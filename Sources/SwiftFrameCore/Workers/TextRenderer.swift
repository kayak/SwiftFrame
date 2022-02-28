import AppKit
import Foundation

final class TextRenderer {

    static let pointSizeTolerance: CGFloat = 1e-7
    static let minFontSize: CGFloat = 1

    // MARK: - Frame Rendering

    func renderText(forKey key: String, locale: String, deviceIdentifier: String, alignment: TextAlignment, rect: NSRect, context: GraphicsContext) throws {
        let attributedString = try AttributedStringCache.shared.attributedString(forTitleIdentifier: key, locale: locale, deviceIdentifier: deviceIdentifier)

        context.cg.saveGState()

        let frame = try makeFrame(from: attributedString, in: rect, alignment: alignment)
        CTFrameDraw(frame, context.cg)
        context.cg.restoreGState()
    }

    private func makeFrame(from attributedString: NSAttributedString, in rect: NSRect, alignment: TextAlignment) throws -> CTFrame {
        let textSize = TextRenderer.attributedStringSize(attributedString, maxWidth: rect.width)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)

        let alignedRect = try calculateAlignedRect(size: textSize, outerFrame: rect, alignment: alignment)
        let path = CGPath(rect: alignedRect, transform: nil)

        return CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: attributedString.length), path, nil)
    }

    func calculateAlignedRect(size: CGSize, outerFrame: CGRect, alignment: TextAlignment) throws -> CGRect {
        guard size <= outerFrame.size else {
            throw NSError(description: "Calculated text size was bigger than bounding rect's size")
        }

        let originY: CGFloat
        switch alignment.vertical {
        case .top:
            let baseOriginY = outerFrame.origin.y + (outerFrame.height - size.height)
            originY = baseOriginY
        case .center:
            let baseOriginY = outerFrame.origin.y + ((outerFrame.height / 2) - (size.height / 2))
            originY = baseOriginY
        case .bottom:
            originY = outerFrame.origin.y
        }

        return CGRect(x: outerFrame.origin.x, y: originY, width: outerFrame.width, height: size.height)
    }

    // MARK: - Fitting & Size Computations

    /// Determines the maximum point size of the specified font that allows to render the given text onto a
    /// particular number of lines
    static func maximumFontSizeThatFits(string: String, font: NSFont, alignment: TextAlignment, maxSize: CGFloat, size: CGSize) throws -> CGFloat {
        guard !string.isEmpty else {
            // Will be skipped during rendering anyways and won't affect text group's max size negatively, so it's okay to
            // return maxSize here
            return maxSize
        }

        let calculatedFontSize = try maxFontSizeThatFits(
            string: string,
            font: font,
            alignment: alignment,
            minSize: TextRenderer.minFontSize,
            maxSize: maxSize,
            size: size)
        // Subtract some small number to make absolutely sure text will be rendered completely
        return min(calculatedFontSize.rounded(.down), maxSize)
    }

    private static func maxFontSizeThatFits(string: String, font: NSFont, alignment: TextAlignment, minSize: CGFloat, maxSize: CGFloat, size: CGSize) throws -> CGFloat {
        let fontSize = (minSize + maxSize) / 2
        let adaptedFont = font.ky_toFont(ofSize: fontSize)

        // Need to use attributed strings since it may contain bold parts which are wider than their non-bold counterpart
        let attributedString = try makeAttributedString(for: string, font: adaptedFont, alignment: alignment)

        // if the search range is smaller than 1e-5 of a font size we stop
        // returning either side of min or max depending on the state
        guard abs(maxSize - minSize) > TextRenderer.pointSizeTolerance else {
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

    private static func formattedString(_ attributedString: NSAttributedString, fitsIntoRect desiredSize: CGSize) -> Bool {
        let stringSize = attributedStringSize(attributedString, maxWidth: desiredSize.width)
        return stringSize <= desiredSize
    }

    private static func attributedStringSize(_ attributedString: NSAttributedString, maxWidth: CGFloat) -> CGSize {
        let constraintSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)

        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        return CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRange(location: 0, length: attributedString.length),
            nil,
            constraintSize,
            nil
        )
    }

    // MARK: - Misc
    
    static func makeAttributedString(for string: String, font: NSFont, color: NSColor = .white, alignment: TextAlignment) throws -> NSAttributedString {
        let attributedString: NSMutableAttributedString
        // Currently the HTML tag support is limited, and the font information is only carried over if the font is provided using the .ttc format
        // and the font is installed on the computer. Hence only using the HTML parsing if the string contains HTML tags
        if string.ky_containsHTMLTags() {
            attributedString = try makeHTMLAttributedString(for: string, font: font, color: color)
        } else {
            attributedString = NSMutableAttributedString(
                string: string,
                attributes: [.font: font, .foregroundColor: color]
            )
        }
        attributedString.setAlignment(alignment.horizontal.nsAlignment, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }

    private static func makeHTMLAttributedString(for htmlString: String, font: NSFont, color: NSColor = .white) throws -> NSMutableAttributedString {
        let htmlString = makeHTMLFormattedString(for: htmlString, font: font, color: color)
        guard let stringData = htmlString.data(using: .utf8) else {
            throw NSError(description: "Could not make attributed string for string \"\(htmlString)\"")
        }
        let attributedString = try NSMutableAttributedString.ky_makeFromHTMLData(stringData)
        return attributedString
    }

    private static func makeHTMLFormattedString(for text: String, font: NSFont, color: NSColor) -> String {
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

private func >=(lhs: CGSize, rhs: CGSize) -> Bool {
    lhs.width >= rhs.width && lhs.height >= rhs.height
}

private func <=(lhs: CGSize, rhs: CGSize) -> Bool {
    lhs.width <= rhs.width && lhs.height <= rhs.height
}
