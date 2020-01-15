import AppKit
import Foundation

final class FontRegistry {

    // MARK: - Properties

    static var shared = FontRegistry()

    private var registeredFontPaths = [String]()

    // MARK: - Font Handling

    /// Registers the font file at the specified path and returns the font name argument that needs to be passed
    /// into `NSFont` for instantiating it
    func registerFont(atPath path: String) throws -> String {
        guard FileManager.default.fileExists(atPath: path) else {
            throw NSError(description: "Font file at \(path) does not exist")
        }
        let url = URL(fileURLWithPath: path)
        var error: Unmanaged<CFError>? = nil
        defer {
            error?.release()
        }

        if !registeredFontPaths.contains(path) {
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                throw NSError(description: error?.takeRetainedValue().localizedDescription ?? "Failed to load font file at \(url.absoluteString)")
            }
            registeredFontPaths.append(path)
        }
        return try fontName(from: url)
    }

    private func fontName(from url: URL) throws -> String {
        guard
            let descriptor = (CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor])?.first,
            let name = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String
        else {
            throw NSError(description: "Failed to load font descriptors from file at \(url.absoluteString)")
        }
        return name
    }

}
