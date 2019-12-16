import AppKit
import Foundation

final class FontRegistry {

    /// Registers the font file at the specified path and returns the font name argument that needs to be passed
    /// into `NSFont` for instantiating it
    func registerFont(atURL url: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: url.absoluteString) else {
            throw NSError(description: "Font file at \(url.absoluteString) does not exist")
        }
        var error: Unmanaged<CFError>? = nil
        defer {
            error?.release()
        }
        if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
            throw NSError(description: error?.takeRetainedValue().localizedDescription ?? "Failed to load font file at \(url.absoluteString)")
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
