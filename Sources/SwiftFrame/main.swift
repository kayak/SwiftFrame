import AppKit
import CoreGraphics
import Foundation
import SwiftFrameCore

do {

    let parseResult = try CommandParser.parse(CommandLine.arguments)

    let processor = try ConfigProcessor(filePath: parseResult.path, verbose: parseResult.verbose)
    try processor.validate()
    try processor.run()

} catch let error as NSError {
    // The cast to `NSError` is mandatory here or otherwise the program will die with a segfault when built through `xcodebuild`.
    // Interestingly, the same does not happen when building with Xcode directly.
    print(CommandLineFormatter.formatError("\(error.localizedDescription)"))
    exit(1)
}
