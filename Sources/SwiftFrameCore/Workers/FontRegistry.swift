import AppKit
import Foundation

final class FontRegistry {

    // MARK: - Properties

    static var shared = FontRegistry()

    // Key is path on file system, element is the corresponding font name
    private var registeredFontPaths = [String: String]()

    // MARK: - Font Handling

    // We have to parse and create the attributed string on the main thread since it uses WebKit according to this SO answer:
    // https://stackoverflow.com/questions/4217820/convert-html-to-nsattributedstring-in-ios/34190968#34190968
    func makeAttributedString(from data: Data) -> NSMutableAttributedString? {
        if !Thread.isMainThread {
            return DispatchQueue.main.sync { makeAttributedString(from: data) }
        }

        return NSMutableAttributedString(html: data, documentAttributes: nil)
    }

    /// Registers the font at the specified path if source is a file rather than `NSFont`
    @discardableResult func registerFont(from source: FontSource) throws -> NSFont {
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
        var error: Unmanaged<CFError>?
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

        // If we're dealing with a ttc file, it can contain multiple weights and font styles. If we arbitrarily choose the first descriptor in the file,
        // we could end up with the bold version of the font for example which would then kill of any <b> tags in the string files
        let descriptor: CTFontDescriptor? = descriptors.count > 1
            ? descriptors.first(where: { CTFontDescriptorCopyAttribute($0, kCTFontStyleNameAttribute) as? String == "Regular" }) ?? descriptors.first
            : descriptors.first

        guard let unwrappedDescriptor = descriptor, let name = CTFontDescriptorCopyAttribute(unwrappedDescriptor, kCTFontNameAttribute) as? String else {
            throw NSError(description: "Failed to load font descriptors from file at \(url.absoluteString)")
        }
        return name
    }

}
