import Foundation

// MARK: - Option Class

public final class CommandLineOption {

    let flags: [String]

    let usageText: String
    let argumentPlaceholder: String?

    let numArgsRequired: Int
    let isRepeatable: Bool

    let group: Int?

    public private(set) var isSpecified = false
    public private(set) var arguments = [String]()

    // MARK: - Object Lifecycle

    init(flags: [String], usageText: String, argumentPlaceholder: String?, numArgsRequired: Int, isRepeatable: Bool, group: Int? = nil) {
        self.flags = flags
        self.usageText = usageText
        self.argumentPlaceholder = argumentPlaceholder
        self.numArgsRequired = numArgsRequired
        self.isRepeatable = isRepeatable
        self.group = group
    }

    // MARK: - Argument Parsing

    /// Reads arguments for the receiver from the `arguments` array starting at `index` and returns the number of arguments consumed
    func parse(_ arguments: [String], at index: Int) -> Int {
        if flags.contains(arguments[index]) && arguments.count >= index + 1 + numArgsRequired {
            isSpecified = true
            let args = arguments[index + 1 ..< index + 1 + numArgsRequired]
            if isRepeatable {
                self.arguments.append(contentsOf: args)
            } else {
                self.arguments = Array(args)
            }
            return 1 + numArgsRequired
        }
        return 0
    }

}

// MARK: - Option Collection

public final class CommandLineOptions {

    // MARK: - Init

    public init() {}

    // MARK: - Options

    public let help = CommandLineOption(
        flags: ["-h", "--help"],
        usageText: "Display this message and exit",
        argumentPlaceholder: nil,
        numArgsRequired: 0,
        isRepeatable: false)

    public let configPath = CommandLineOption(
        flags: ["-c", "--config"],
        usageText: "Read configuration values from the specified file",
        argumentPlaceholder: "PATH",
        numArgsRequired: 1,
        isRepeatable: false)

    public let verbose = CommandLineOption(
        flags: ["-v", "--verbose"],
        usageText: "Print logging information to STDOUT",
        argumentPlaceholder: nil,
        numArgsRequired: 0,
        isRepeatable: false)

    private var all: [CommandLineOption] {
        return [help, configPath, verbose]
    }

    // MARK: - Parsing & Validation

    public func parse(arguments: [String]) throws {
        let remainder = parse(Array(arguments.suffix(from: 1)), at: 0)
        try validate(remainder: remainder)
    }

    private func parse(_ arguments: [String], at index: Int) -> [String] {
        guard index < arguments.count else {
            return []
        }
        for option in all {
            let numArgsRead = option.parse(arguments, at: index)
            if numArgsRead > 0 {
                return parse(arguments, at: index + numArgsRead)
            }
        }
        return Array(arguments.suffix(from: index))
    }

    private func validate(remainder: [String]) throws {
        guard !help.isSpecified else {
            return
        }
        guard remainder.isEmpty else {
            throw NSError(description: "Unhandled argument remainder \(remainder)")
        }
    }

    // MARK: - Usage Info

    public func summarizeUsage() -> String {
        var lines = [String]()
        let flags = all.map({ $0.flags.joined(separator: ", ") + "\($0.argumentPlaceholder != nil ? " \($0.argumentPlaceholder!)" : "")"})
        let maxFlagLength = flags.map({ $0.count }).max()!
        let usageTexts = all.map({ $0.usageText.toFuzzyLines(ofLength: 50, breakingOn: " ") })
        for (flag, usageText) in zip(flags, usageTexts) {
            lines.append("\(flag.toWidth(maxFlagLength))  \(usageText.first!)")
            for line in Array(usageText.suffix(from: 1)) {
                lines.append("\("".toWidth(maxFlagLength))  \(line)")
            }
        }
        return lines.joined(separator: "\n")
    }

}
