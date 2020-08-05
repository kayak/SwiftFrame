import AppKit
import CoreGraphics
import Foundation
import SwiftFrameCore
import ArgumentParser

extension URL: ExpressibleByArgument {

    public init?(argument: String) {
        self.init(fileURLWithPath: argument)
    }

}

// Struct name serves as command name
struct SwiftFrame: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "swiftframe",
        abstract: "CLI application for speedy screenshot framing",
        version: "2.2.0",
        helpNames: .shortAndLong)

    @Flag(name: .shortAndLong, help: "Prints additional information and lets you verify the config file before rendering")
    var verbose = false

    @Option(name: .shortAndLong, help: "Read configuration values from the specified file")
    var configPath: URL

    func run() throws {
        runWrapped()
    }

    private func runWrapped() {
        do {
            let processor = try ConfigProcessor(configURL: configPath, verbose: verbose)
            try processor.validate()
            try processor.run()
        } catch let error as NSError {
            let errorMessage = verbose
                ? CommandLineFormatter.formatError(error.description)
                : CommandLineFormatter.formatError(error.localizedDescription)
            print(errorMessage)

            error.expectation.flatMap { print(CommandLineFormatter.formatWarning(title: "Expectation", text: $0)) }
            error.actualValue.flatMap { print(CommandLineFormatter.formatWarning(title: "Actual", text: $0)) }

            if !verbose {
                print("Use --verbose to get additional error information")
            }

            Darwin.exit(Int32(error.code))
        }
    }

}

SwiftFrame.main()
