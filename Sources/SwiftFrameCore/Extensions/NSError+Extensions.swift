import Foundation

public extension NSError {

    convenience init(code: Int = 1, description: String) {
        self.init(domain: "com.kayak.SwiftFrame", code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }

}

public func ky_executeOrExit<T>(_ work: () throws -> T) -> T {
    do {
        return try work()
    } catch let error as NSError {
        print(CommandLineFormatter.formatError(error.localizedDescription))
        exit(Int32(error.code))
    }
}
