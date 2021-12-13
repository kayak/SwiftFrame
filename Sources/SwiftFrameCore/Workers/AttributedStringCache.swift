import AppKit
import Foundation

// Used for keeping attributed strings that were parsed on the main thread in memory for asynchronous processing
final class AttributedStringCache: NSObject {

    // MARK: - Nested Type

    enum FontMode {
        case dynamic(maxSize: CGFloat)
        case fixed(pointSize: CGFloat)
    }

    // MARK: - Properties

    static let shared = AttributedStringCache()
    private var cache = [String: NSAttributedString]()

    // MARK: - Reading/Writing to cache

    func attributedString(forTitleIdentifier titleIdentifier: String, locale: String, deviceIdentifier: String) throws -> NSAttributedString {
        let identifier = makeCacheIdentifier(titleIdentifier: titleIdentifier, locale: locale, deviceIdentifier: deviceIdentifier)
        guard let value = cache[identifier] else {
            throw NSError(description: "Could not find value for key \"\(identifier)\" in attributed string cache")
        }
        return value
    }

    func process(
        _ associatedStrings: [AssociatedString],
        locale: String,
        deviceIdentifier: String,
        maxFontSizeByGroup: [String: CGFloat],
        font: NSFont,
        color: NSColor,
        maxFontSize: CGFloat
    ) throws {
        guard Thread.current.isMainThread else {
            throw NSError(description: "Attributed string processing has to be done on the main thread")
        }
        try associatedStrings.forEach { string, textData in
            let fontMode: FontMode
            if let sharedSize = textData.groupIdentifier.flatMap({ maxFontSizeByGroup[$0] }) {
                // Can use fixed font size since common maximum has already been calculated
                fontMode = .fixed(pointSize: sharedSize)
            } else {
                fontMode = .dynamic(maxSize: textData.maxFontSizeOverride ?? maxFontSize)
            }

            try add(
                title: string,
                locale: locale,
                deviceIdentifier: deviceIdentifier,
                font: textData.fontOverride?.font() ?? font,
                color: textData.textColorOverride ?? color,
                fontMode: fontMode,
                textData: textData
            )
        }
    }

    private func add(title: String, locale: String, deviceIdentifier: String, font: NSFont, color: NSColor, fontMode: FontMode, textData: TextData) throws {
        let fontSize: CGFloat
        switch fontMode {
        case let .dynamic(maxSize: maxSize):
            fontSize = try TextRenderer.maximumFontSizeThatFits(
                string: title,
                font: font,
                alignment: textData.textAlignment,
                maxSize: maxSize,
                size: textData.rect.size
            )
        case let .fixed(pointSize: size):
            fontSize = size
        }
        let adaptedFont = font.ky_toFont(ofSize: fontSize)
        let attributedString = try TextRenderer.makeAttributedString(for: title, font: adaptedFont, color: color, alignment: textData.textAlignment)

        let identifier = makeCacheIdentifier(titleIdentifier: textData.titleIdentifier, locale: locale, deviceIdentifier: deviceIdentifier)
        #if DEBUG
        print("Caching attributed string with key:", identifier, "point size:", fontSize)
        #endif
        if cache[identifier] != nil {
            throw NSError(description: "Attempted to override cached attributed string for key \"\(identifier)\"")
        }
        cache[identifier] = attributedString
    }

    private func makeCacheIdentifier(titleIdentifier: String, locale: String, deviceIdentifier: String) -> String {
        [locale, titleIdentifier, deviceIdentifier].joined(separator: "_")
    }

}
