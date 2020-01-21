import Foundation

public extension NSError {

    convenience init(code: Int = 1, description: String) {
        self.init(domain: "com.kayak.SwiftFrame", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }

}
