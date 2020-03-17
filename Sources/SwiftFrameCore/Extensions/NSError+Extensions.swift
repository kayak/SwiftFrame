import Foundation

public extension NSError {

    static let kFailedExpectationKey = "kFailedExpectationKey"

    convenience init(code: Int = 1, description: String, expectation: String? = nil) {
        self.init(
            domain: "com.kayak.SwiftFrame",
            code: code,
            userInfo: [
                NSLocalizedDescriptionKey: description,
                NSError.kFailedExpectationKey: expectation
            ])
    }

    var failedExpectation: String? {
        userInfo[NSError.kFailedExpectationKey] as? String
    }

}

public func ky_executeOrExit<T>(_ work: () throws -> T) -> T {
    do {
        return try work()
    } catch let error as NSError {
        print(CommandLineFormatter.formatError(error.localizedDescription))
        error.failedExpectation.flatMap { print(CommandLineFormatter.formatWarning($0)) }
        exit(Int32(error.code))
    }
}
