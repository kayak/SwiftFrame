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

    func registerFont(atPath path: String, with size: CGFloat = 20) throws -> NSFont {
        let fontName = try registerFont(atPath: path)
        guard let font = NSFont(name: fontName, size: size) else {
            throw NSError(description: "Failed to load title font with name \(fontName)")
        }
        return font
    }

    private func fontName(from url: URL) throws -> String {
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
