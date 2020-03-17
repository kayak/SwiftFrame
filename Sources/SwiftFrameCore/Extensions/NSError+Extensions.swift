import Foundation

public extension NSError {

    static let kExpectationKey = "kExpectationKey"
    static let kActualValueKey = "kActualValueKey"

    convenience init(code: Int = 1, description: String, expectation: String? = nil, actualValue: String? = nil) {
        self.init(
            domain: "com.kayak.SwiftFrame",
            code: code,
            userInfo: [
                NSLocalizedDescriptionKey: description,
                NSError.kExpectationKey: expectation as Any,
                NSError.kActualValueKey: actualValue as Any
            ])
    }

    // Not too sure about this naming yet

    var failedExpectation: String? {
        userInfo[NSError.kExpectationKey] as? String
    }

    var actualValue: String? {
        userInfo[NSError.kActualValueKey] as? String
    }

}

public func ky_executeOrExit<T>(_ work: () throws -> T) -> T {
    do {
        return try work()
    } catch let error as NSError {
        print(CommandLineFormatter.formatError(error.localizedDescription))
        error.failedExpectation.flatMap { print(CommandLineFormatter.formatWarning(title: "Expectation", text: $0)) }
        error.actualValue.flatMap { print(CommandLineFormatter.formatWarning(title: "Actual", text: $0)) }
        exit(Int32(error.code))
    }
}
