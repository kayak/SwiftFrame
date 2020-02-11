import AppKit
import CoreGraphics
import Foundation
import SwiftFrameCore

do {

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
    let configURL = URL(fileURLWithPath: configPath)
    let data = try Data(contentsOf: configURL)
    
    var config = try JSONDecoder().decode(ConfigData.self, from: data)
    let verbose = options.verbose.isSpecified

    try config.process()
    try config.validate()

    if verbose {
        config.printSummary(insetByTabs: 0)
        print("Press return key to continue")
        _ = readLine()
    }

    print("Parsed and validated config file\n")

    // Run and measure elapsed time
    let start = CFAbsoluteTimeGetCurrent()

    try config.run(verbose)

    let diff = CFAbsoluteTimeGetCurrent() - start
    print("All done!".formattedGreen())

    if verbose {
        print("Rendered and sliced screenshots in \(String(format: "%.2f", diff)) seconds")
    }

} catch let error as NSError {
    // The cast to `NSError` is mandatory here or otherwise the program will die with a segfault when built through `xcodebuild`.
    // Interestingly, the same does not happen when building with Xcode directly.
    print(CommandLineFormatter.formatError("\(error.localizedDescription)"))
    print(error)
    exit(1)
}
