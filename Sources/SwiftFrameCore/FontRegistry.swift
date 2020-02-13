import AppKit
import Foundation

final class FontRegistry {

    // MARK: - Properties

    static var shared = FontRegistry()

    private let queue = DispatchQueue(label: "font_registry_queue")
    private var registeredFontPaths = [String: String]()

    // MARK: - Font Handling

    func makeAttributedString(from data: Data) -> NSMutableAttributedString? {
        queue.sync {
            try? NSMutableAttributedString(html: stringData, documentAttributes: nil)
        }
    }

    /// Registers the font at the specified path if source is a file rather than `NSFont`
    func registerFont(from source: FontSource) throws -> NSFont {
        try queue.sync {
            try threadSafeRegisterFont(from: source)
        }
    }

    private func threadSafeRegisterFont(from source: FontSource) throws -> NSFont {
        switch source {
        case let .nsFont(font):
            return font
        case let .filePath(path):
            return try registerFont(atPath: path)
        }
    }

    private func registerFont(atPath path: String, with size: CGFloat = 20) throws -> NSFont {
        guard FileManager.default.fileExists(atPath: path) else {
            throw NSError(description: "Font file at \(path) does not exist")
        }
        let url = URL(fileURLWithPath: path)
        var error: Unmanaged<CFError>? = nil
        defer {
            error?.release()
        }

        let fontName: String
        if let registeredFont = registeredFontPaths[url.absoluteString] {
            fontName = registeredFont
        } else {
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                throw NSError(description: error?.takeRetainedValue().localizedDescription ?? "Failed to load font file at \(url.absoluteString)")
            }
            let newFontName = try getFontName(from: url)
            registeredFontPaths[url.absoluteString] = newFontName
            fontName = newFontName
        }

        guard let font = NSFont(name: fontName, size: size) else {
            throw NSError(description: "Failed to load title font with name \(fontName)")
        }
        return font
    }

    private func getFontName(from url: URL) throws -> String {
        guard let descriptors = (CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor]) else {
            throw NSError(description: "Failed to load font descriptors from file at \(url.absoluteString)")
        }

        let descriptor: CTFontDescriptor? = descriptors.count > 1
            ? descriptors.first(where: { CTFontDescriptorCopyAttribute($0, kCTFontStyleNameAttribute) as? String == "Regular" }) ?? descriptors.first
            : descriptors.first

        guard let unwrappedDescriptor = descriptor, let name = CTFontDescriptorCopyAttribute(unwrappedDescriptor, kCTFontNameAttribute) as? String else {
            throw NSError(description: "Failed to load font descriptors from file at \(url.absoluteString)")
        }
        return name
    }

}
