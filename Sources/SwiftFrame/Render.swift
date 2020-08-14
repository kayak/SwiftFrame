import AppKit
import CoreGraphics
import Foundation
import SwiftFrameCore
import ArgumentParser

struct Render: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "Parses, validates and processes the passed in config file",
        helpNames: .shortAndLong)

    @Argument(help: "Read configuration values from the specified file", completion: .list(["config", "yml", "yaml"]))
    var configFilePath: String

    @Flag(name: .shortAndLong, help: "Prints additional information and lets you verify the config file before rendering")
    var verbose = false

    func run() throws {
        let configFileURL = URL(fileURLWithPath: configFilePath)

        ky_runWrapped(verbose: verbose) {
            let processor = try ConfigProcessor(configURL: configFileURL, verbose: verbose)
            try processor.validate()
            try processor.run()
        }
    }

}

func ky_runWrapped(verbose: Bool, _ work: () throws -> Void) {
    do {
        try work()
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
