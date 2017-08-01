import AppKit
import Foundation

extension NSFont {

    func toFont(ofSize size: CGFloat) -> NSFont {
        return NSFontManager.shared().convert(self, toSize: size)
    }

}
