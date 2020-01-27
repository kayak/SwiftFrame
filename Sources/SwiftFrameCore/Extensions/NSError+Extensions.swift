import Foundation

public extension NSError {

    func withDescription(_ message: String) -> NSError {
        var dict = userInfo
        dict[NSLocalizedDescriptionKey] = message
        return NSError(domain: domain, code: code, userInfo: dict)
    }

    convenience init(code: Int = 1, description: String) {
        self.init(domain: "com.kayak.SwiftFrame", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }

}
