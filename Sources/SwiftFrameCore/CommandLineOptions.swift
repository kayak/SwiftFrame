import Foundation

// MARK: - Option Class

final class CommandLineOption {

    let flags: [String]

    let usageText: String
    let argumentPlaceholder: String?

    let numArgsRequired: Int
    let isRepeatable: Bool

    let group: Int?

    private(set) var isSpecified = false
    private(set) var arguments = [String]()

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

final class CommandLineOptions {

    // MARK: - Options

    let help = CommandLineOption(
        flags: ["-h", "--help"],
        usageText: "Display this message and exit",
        argumentPlaceholder: nil,
        numArgsRequired: 0,
        isRepeatable: false)

    let configPath = CommandLineOption(
        flags: ["-c", "--config"],
        usageText: "Read configuration values from the specified file",
        argumentPlaceholder: "PATH",
        numArgsRequired: 1,
        isRepeatable: false)

    let background = CommandLineOption(
        flags: ["-b", "--background"],
        usageText: "Specification for how to fill the background. Can either be a solid color in hex form (CSS-shorthand notation supported) " +
            "or a linear gradient in CSS notation (diagonals and non-hex color notation not supported).",
        argumentPlaceholder: "HEX_STRING",
        numArgsRequired: 1,
        isRepeatable: false)

    let framePath = CommandLineOption(
        flags: ["-d", "--device-frame"],
        usageText: "The device frame image",
        argumentPlaceholder: "PATH",
        numArgsRequired: 1,
        isRepeatable: false)

    let frameViewport = CommandLineOption(
        flags: ["-dv", "--device-viewport"],
        usageText: "Optional. The coordinates of the device frame's viewport with respect to its own coordinate system."
            + " (X1,Y1) and (X2,Y2) are the coordinates of the top left and bottom right corner, respectively."
            + " Values should be supplied as integers. If omitted, the viewport is determined programmatically by"
            + " analyzing the frame image.",
        argumentPlaceholder: "\"X1 Y1 X2 Y2\"",
        numArgsRequired: 1,
        isRepeatable: false)

    let framePadding = CommandLineOption(
        flags: ["-dp", "--device-padding"],
        usageText: "The horizontal padding used to surround the device frame",
        argumentPlaceholder: "INT",
        numArgsRequired: 1,
        isRepeatable: false)

    let frameHasNotch = CommandLineOption(
        flags: ["-dn", "--device-frame-has-notch"],
        usageText: "If specified, the frame has a notch and will be treated accordingly",
        argumentPlaceholder: nil,
        numArgsRequired: 0,
        isRepeatable: false)

    let screenshotPath = CommandLineOption(
        flags: ["-s", "--screenshot"],
        usageText: "The screenshot image. Can be supplied multiple times.",
        argumentPlaceholder: "PATH",
        numArgsRequired: 1,
        isRepeatable: true)

    let screenshotDirectory = CommandLineOption(
        flags: ["-sd", "--screenshot-directory"],
        usageText: "The directory containing the screenshots",
        argumentPlaceholder: "PATH",
        numArgsRequired: 1,
        isRepeatable: false)

    let downsampling = CommandLineOption(
        flags: ["-ad", "--allow-downsampling"],
        usageText: "If specified, screenshots are scaled down to match the device's viewport when required",
        argumentPlaceholder: nil,
        numArgsRequired: 0,
        isRepeatable: false)

    let titleText = CommandLineOption(
        flags: ["-t", "--title-text"],
        usageText: "The title text. Can be supplied multiple times.",
        argumentPlaceholder: "STRING",
        numArgsRequired: 1,
        isRepeatable: true)

    let titleTexts = CommandLineOption(
        flags: ["-tt", "--title-texts"],
        usageText: "File containing the title texts. One line is expected for each screenshot supplied. The file should be UTF-8 encoded.",
        argumentPlaceholder: "STRING",
        numArgsRequired: 1,
        isRepeatable: false)

    let titleFontPath = CommandLineOption(
        flags: ["-tf", "--title-font"],
        usageText: "The font file to be used for rendering the title",
        argumentPlaceholder: "PATH",
        numArgsRequired: 1,
        isRepeatable: false)

    let titleColor = CommandLineOption(
        flags: ["-tc", "--title-color"],
        usageText: "The title text color",
        argumentPlaceholder: "HEX_STRING",
        numArgsRequired: 1,
        isRepeatable: false)

    let titlePadding = CommandLineOption(
        flags: ["-tp", "--title-padding"],
        usageText: "The padding used to surround the title text. Values should be supplied as integers.",
        argumentPlaceholder: "\"TOP LEFT BOTTOM RIGHT\"",
        numArgsRequired: 1,
        isRepeatable: false)

    let outputPath = CommandLineOption(
        flags: ["-o", "--output"],
        usageText: "The path under which to store the resulting PNG. Can be supplied multiple times.",
        argumentPlaceholder: "PATH",
        numArgsRequired: 1,
        isRepeatable: true)

    let outputSuffix = CommandLineOption(
        flags: ["-os", "--output-suffix"],
        usageText: "The suffix to append to screenshot names when writing the framed output.",
        argumentPlaceholder: "STRING",
        numArgsRequired: 1,
        isRepeatable: false)

    let verbose = CommandLineOption(
        flags: ["-v", "--verbose"],
        usageText: "Print logging information to STDOUT",
        argumentPlaceholder: nil,
        numArgsRequired: 0,
        isRepeatable: false)

    private var all: [CommandLineOption] {
        return [help, configPath, background, framePath, frameViewport, framePadding, frameHasNotch, screenshotPath, screenshotDirectory,
            downsampling, titleText, titleTexts, titleFontPath, titleColor, titlePadding, outputPath, outputSuffix, verbose]
    }

    // MARK: - Parsing & Validation

    func parse(arguments: [String]) throws {
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

    func summarizeUsage() -> String {
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
