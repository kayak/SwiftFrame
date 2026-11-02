import AppKit
import Foundation
import Synchronization

// Used for keeping attributed strings that were parsed on the main thread in memory for asynchronous processing
final class AttributedStringCache: NSObject, Sendable {

    // MARK: - Nested Type

    enum FontMode {
        case dynamic(maxSize: CGFloat)
        case fixed(pointSize: CGFloat)
    }

    /// An attributed string that threads can share.
    ///
    /// This type is `@unchecked Sendable` because `NSAttributedString` is not `Sendable` on macOS. This is safe: the initializer
    /// makes an immutable copy, nothing keeps a mutable reference to that copy, and immutable `NSAttributedString` objects are thread-safe.
    private struct SharedAttributedString: @unchecked Sendable {

        let value: NSAttributedString

        init(copying string: NSAttributedString) {
            value = NSAttributedString(attributedString: string)
        }

    }

    // MARK: - Properties

    static let shared = AttributedStringCache()
    private let cache = Mutex<[String: SharedAttributedString]>([:])

    // MARK: - Reading/Writing to cache

    func attributedString(forTitleIdentifier titleIdentifier: String, locale: String, deviceIdentifier: String) throws -> NSAttributedString
    {
        let identifier = makeCacheIdentifier(titleIdentifier: titleIdentifier, locale: locale, deviceIdentifier: deviceIdentifier)
        guard let sharedString = cache.withLock({ $0[identifier] }) else {
            throw NSError(description: "Could not find value for key \"\(identifier)\" in attributed string cache")
        }
        return sharedString.value
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
        for (string, textData) in associatedStrings {
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

    private func add(
        title: String,
        locale: String,
        deviceIdentifier: String,
        font: NSFont,
        color: NSColor,
        fontMode: FontMode,
        textData: TextData
    ) throws {
        let fontSize: CGFloat
        switch fontMode {
        case .dynamic(let maxSize):
            fontSize = try TextRenderer.maximumFontSizeThatFits(
                string: title,
                font: font,
                alignment: textData.textAlignment,
                maxSize: maxSize,
                size: textData.rect.size
            )
        case .fixed(let pointSize):
            fontSize = pointSize
        }
        let adaptedFont = font.ky_toFont(ofSize: fontSize)
        let attributedString = try TextRenderer.makeAttributedString(
            for: title,
            font: adaptedFont,
            color: color,
            alignment: textData.textAlignment
        )

        let identifier = makeCacheIdentifier(titleIdentifier: textData.titleIdentifier, locale: locale, deviceIdentifier: deviceIdentifier)
        #if DEBUG
        print("Caching attributed string with key:", identifier, "point size:", fontSize)
        #endif
        let sharedString = SharedAttributedString(copying: attributedString)
        try cache.withLock { cache in
            if cache[identifier] != nil {
                throw NSError(description: "Attempted to override cached attributed string for key \"\(identifier)\"")
            }
            cache[identifier] = sharedString
        }
    }

    private func makeCacheIdentifier(titleIdentifier: String, locale: String, deviceIdentifier: String) -> String {
        [locale, titleIdentifier, deviceIdentifier].joined(separator: "_")
    }

}
