import AppKit
import Foundation

extension NSFont {

    func ky_toFont(ofSize size: CGFloat) -> NSFont {
        NSFontManager.shared.convert(self, toSize: size)
    }

}
