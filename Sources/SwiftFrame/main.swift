import AppKit
import CoreGraphics
import Foundation
import SwiftFrameCore
import ArgumentParser

struct SwiftFrame: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "swiftframe",
        abstract: "CLI application for speedy screenshot framing",
        version: "3.1.1",
        helpNames: .shortAndLong)

    @Argument(help: "Read configuration values from the specified file", completion: .list(["config", "json", "yml", "yaml"]))
    var configFilePath: String

    @Flag(name: .shortAndLong, help: "Prints additional information and lets you verify the config file before rendering")
    var verbose = false

    func run() throws {
        let configFileURL = URL(fileURLWithPath: configFilePath)

        do {
            let processor = try ConfigProcessor(configURL: configFileURL, verbose: verbose)
            try processor.validate()
            try processor.run()
        } catch let error as NSError {
            let errorMessage = verbose
                ? CommandLineFormatter.formatError(error.description)
                : CommandLineFormatter.formatError(error.localizedDescription)
            print(errorMessage)

            error.expectation.flatMap { print(CommandLineFormatter.formatWarning(title: "Expectation", text: $0)) }
            error.actualValue.flatMap { print(CommandLineFormatter.formatWarning(title: "Actual", text: $0)) }

            Darwin.exit(Int32(error.code))
        }
    }

}

SwiftFrame.main()
