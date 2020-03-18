import AppKit
import CoreGraphics
import Foundation
import SwiftFrameCore
import ArgumentParser

// Struct name serves as command name
struct SwiftFrame: ParsableCommand {

    @Flag(help: "Prints additional information and lets you verify the config file before rendering")
    var verbose: Bool

    @Option(name: .shortAndLong, help: "Read configuration values from the specified file")
    var configPath: String

}

// We need this small wrapper to retain out nicely formatted error logging
ky_executeOrExit {
    let instance = try SwiftFrame.parse()

    let processor = try ConfigProcessor(filePath: instance.configPath, verbose: instance.verbose)
    try processor.validate()
    try processor.run()
}
