import AppKit
import CoreGraphics
import Foundation
import SwiftFrameCore
import ArgumentParser

// Struct name serves as command name
struct SwiftFrame: ParsableCommand {

    @Flag(help: "Prints additional information and lets you verify the config file before rendering")
    var verbose = false

    @Option(name: .shortAndLong, help: "Read configuration values from the specified file")
    var configPath: String

    func run() throws {
        runWrapped()
    }

    private func runWrapped() {
        do {
            let processor = try ConfigProcessor(filePath: configPath, verbose: verbose)
            try processor.validate()
            try processor.run()
        } catch let error as NSError {
            print(CommandLineFormatter.formatError(error.localizedDescription))
            error.expectation.flatMap { print(CommandLineFormatter.formatWarning(title: "Expectation", text: $0)) }
            error.actualValue.flatMap { print(CommandLineFormatter.formatWarning(title: "Actual", text: $0)) }
            Darwin.exit(Int32(error.code))
        }
    }

}

SwiftFrame.main()
