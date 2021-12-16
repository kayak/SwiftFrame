import ArgumentParser
import Foundation
import SwiftFrameCore

struct Render: ParsableCommand {

    @Argument(help: "Read configuration values from the specified file", completion: .list(["config", "json", "yml", "yaml"]))
    var configFilePath: String

    @Flag(name: .shortAndLong, help: "Prints additional information and lets you verify the config file before rendering")
    var verbose = false

    @Flag(name: .long)
    var noManualValidation = false

    @Flag(name: .long)
    var noColorOutput = false

    func run() throws {
        let configFileURL = URL(fileURLWithPath: configFilePath)

        do {
            let processor = try ConfigProcessor(
                configURL: configFileURL,
                verbose: verbose,
                noManualValidation: noManualValidation,
                noColorOutput: noColorOutput
            )
            try processor.validate()
            try processor.run()
        } catch let error {
            ky_exitWithError(error, verbose: verbose)
        }
    }

}
