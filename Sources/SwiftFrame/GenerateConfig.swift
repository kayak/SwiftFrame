import ArgumentParser
import Foundation
import SwiftFrameCore

extension ConfigFileFormat: ExpressibleByArgument {}

struct GenerateConfig: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "Generates a template config file based on user input",
        helpNames: .shortAndLong)

    @Argument(help: "The path where the produced config file should be saved", completion: .file())
    var outputPath: String

    @Option(name: .shortAndLong, help: "The output format of produced config file", completion: .list(["yaml", "yml", "config", "json"]))
    var outputFormat: ConfigFileFormat

    func run() throws {
        let data = try ConfigFactory.createConfig(format: .json)
        try data.write(to: URL(fileURLWithPath: outputPath))
    }

}
