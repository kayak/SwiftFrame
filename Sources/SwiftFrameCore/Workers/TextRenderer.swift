import AppKit
import Foundation

final class TextRenderer {

    private let minFontSize: CGFloat = 1
    static let pointSizeTolerance: CGFloat = 1e-7
    static let verticalAlignmentPadding: CGFloat = 1.2

    // MARK: - Frame Rendering

    func render(text: String, font: NSFont, color: NSColor, alignment: TextAlignment, rect: NSRect, context: CGContext) throws {
        let attributedString = try makeAttributedString(for: text, font: font, color: color, alignment: alignment)

        context.saveGState()
        let frame = makeFrame(from: attributedString, in: rect, alignment: alignment)
        CTFrameDraw(frame, context)
        context.restoreGState()
    }

    private func makeFrame(from attributedText: NSAttributedString, in rect: NSRect, alignment: TextAlignment) -> CTFrame {
        let textRect = attributedText.boundingRect(with: rect.size, options: [.usesLineFragmentOrigin, .usesFontLeading])
        let alignedRect = calculateAlignedRect(innerFrame: textRect, outerFrame: rect, alignment: alignment)

        let path = CGPath(rect: alignedRect, transform: nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        return CTFramesetterCreateFrame(frameSetter, CFRange(location: 0, length: attributedText.length), path, nil)
    }

    private func calculateAlignedRect(innerFrame: CGRect, outerFrame: CGRect, alignment: TextAlignment) -> CGRect {
        let originX: CGFloat
        switch alignment.horizontal {
        case .left, .justify:
            originX = outerFrame.origin.x
        case .right:
            originX = outerFrame.origin.x + (outerFrame.width - innerFrame.width)
        case .center:
            originX = outerFrame.origin.x + ((outerFrame.width - innerFrame.width) / 2)
        }

        let originY: CGFloat
        switch alignment.vertical {
        case .top:
            let baseOriginY = outerFrame.origin.y + (outerFrame.height - innerFrame.height)
            originY = baseOriginY - TextRenderer.verticalAlignmentPadding
        case .center:
            let baseOriginY = outerFrame.origin.y + ((outerFrame.height / 2) - (innerFrame.height / 2))
            originY = baseOriginY - TextRenderer.verticalAlignmentPadding
        case .bottom:
            originY = outerFrame.origin.y
        }

        // We need to add a little bit of padding again, because CoreText has hiccups and struggles to render multi-line text into an exactly fitting rect
        return CGRect(x: originX, y: originY, width: innerFrame.width, height: innerFrame.height + TextRenderer.verticalAlignmentPadding)
    }

    // MARK: - Fitting & Size Computations

    /// Determines the maximum point size of the specified font that allows to render the given text onto a
    /// particular number of lines
    func maximumFontSizeThatFits(string: String, font: NSFont, alignment: TextAlignment, maxSize: CGFloat, size: CGSize) throws -> CGFloat {
        guard !string.isEmpty else {
            throw NSError(description: "Empty string was passed to TextRenderer")
        }

        let calculatedFontSize = try maxFontSizeThatFits(string: string, font: font, alignment: alignment, minSize: minFontSize, maxSize: maxSize, size: size)
        // Subtract some small number to make absolutely sure text will be rendered completely
        return min(calculatedFontSize.rounded(.down) - TextRenderer.pointSizeTolerance, maxSize)
    }

    private func maxFontSizeThatFits(string: String, font: NSFont, alignment: TextAlignment, minSize: CGFloat, maxSize: CGFloat, size: CGSize) throws -> CGFloat {
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

    private func formattedString(_ attributedString: NSAttributedString, fitsIntoRect desiredSize: CGSize) -> Bool {
        let constraintSize = CGSize(width: desiredSize.width, height: CGFloat.greatestFiniteMagnitude)
        let stringSize = attributedString.boundingRect(with: constraintSize, options: [.usesLineFragmentOrigin, .usesFontLeading]).size

        return stringSize.width <= desiredSize.width && stringSize.height <= desiredSize.height
    }

    // MARK: - Misc

    private func makeAttributedString(for htmlString: String, font: NSFont, color: NSColor = .white, alignment: TextAlignment) throws -> NSAttributedString {
        let htmlString = makeHTMLFormattedString(for: htmlString, font: font, color: color)
        guard let stringData = htmlString.data(using: .utf8), let attributedString = NSMutableAttributedString.ky_makeFromHTMLData(stringData) else {
            throw NSError(description: "Could not make attributed string for string \"\(htmlString)\"")
        }
        attributedString.setAlignment(alignment.horizontal.nsAlignment, range: NSRange(location: 0, length: attributedString.length))
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
