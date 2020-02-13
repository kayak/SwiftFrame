import AppKit
import CoreGraphics
import Foundation
import SwiftFrameCore

do {
    print("programm startin...")

    // Read options and parse
    let options = CommandLineOptions()
    try options.parse(arguments: CommandLine.arguments)

    guard !options.help.isSpecified else {
        print(options.summarizeUsage())
        exit(0)
    }

    // Parse config data
    guard let configPath = options.configPath.arguments.first else {
        throw NSError(description: "Please specify a config file path")
    }

    let processor = try ConfigProcessor(filePath: configPath, verbose: options.verbose.isSpecified)
    try processor.validate()
    try processor.run()

} catch let error as NSError {
    // The cast to `NSError` is mandatory here or otherwise the program will die with a segfault when built through `xcodebuild`.
    // Interestingly, the same does not happen when building with Xcode directly.
    print(CommandLineFormatter.formatError("\(error.localizedDescription)"))
    exit(1)
}
