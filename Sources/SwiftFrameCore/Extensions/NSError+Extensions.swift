import Foundation

public extension NSError {

    private static let kExpectationKey = "kExpectationKey"
    private static let kActualValueKey = "kActualValueKey"

    convenience init(code: Int = 1, description: String, expectation: String? = nil, actualValue: String? = nil) {
        self.init(
            domain: "com.kayak.SwiftFrame",
            code: code,
            userInfo: [
                NSLocalizedDescriptionKey: description,
                NSError.kExpectationKey: expectation as Any,
                NSError.kActualValueKey: actualValue as Any
            ]
        )
    }

    var expectation: String? {
        userInfo[NSError.kExpectationKey] as? String
    }

    var actualValue: String? {
        userInfo[NSError.kActualValueKey] as? String
    }

}

func ky_executeOrExit<T>(verbose: Bool = false, _ work: () throws -> T) -> T {
    do {
        return try work()
    } catch let error as NSError {
        ky_exitWithError(error, verbose: verbose)
    }
}

public func ky_exitWithError(_ error: Error, verbose: Bool = false) -> Never {
    let error = error as NSError
    print(CommandLineFormatter.formatError(verbose ? error.description : error.localizedDescription))

    error.expectation.flatMap { print(CommandLineFormatter.formatWarning(title: "EXPECTATION", text: $0)) }
    error.actualValue.flatMap { print(CommandLineFormatter.formatWarning(title: "ACTUAL", text: $0)) }
    exit(Int32(error.code))
}
