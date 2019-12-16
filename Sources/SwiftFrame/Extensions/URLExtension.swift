import AppKit
import Foundation

extension URL {
    func registerFont(at size: CGFloat = 20) throws -> NSFont {
        let fontName = try FontRegistry().registerFont(atURL: self)
        guard let font = NSFont(name: fontName, size: size) else {
            throw NSError(description: "Failed to load title font with name \(fontName)")
        }
        return font
    }
}
