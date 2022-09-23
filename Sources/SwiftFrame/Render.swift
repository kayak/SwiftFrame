import ArgumentParser
import Foundation
import SwiftFrameCore

struct Render: ParsableCommand {

    @Argument(help: "Read configuration values from the specified file", completion: .list(["config", "json", "yml", "yaml"]))
    var configFilePath: String

    @Flag(name: .shortAndLong, help: "Prints additional information and lets you verify the config file before rendering")
    var verbose = false

    @Flag(name: .long, help: "Skips the manual validation step if --verbose/-v is used")
    var noManualValidation = false

    @Flag(name: .long, help: "Disables any colored output")
    var noColorOutput = false

    @Flag(name: .long, help: "Clears any output directory before writing images to prevent leftover images to remain in the directories")
    var clearDirectories = false

    @Flag(
        name: .long,
        help: "Outputs the whole image canvas into the output directories before slicing it up into the correct screenshot sizes. Helpful for troubleshooting"
    )
    var outputWholeImage = false

    func run() throws {
        let configFileURL = URL(fileURLWithPath: configFilePath)

        do {
            let processor = try ConfigProcessor(
                configURL: configFileURL,
                verbose: verbose,
                noManualValidation: noManualValidation,
                outputWholeImage: outputWholeImage,
                clearDirectories: clearDirectories,
                noColorOutput: noColorOutput
            )
            try processor.validate()
            try processor.run()
        } catch let error {
            ky_exitWithError(error, verbose: verbose)
        }
    }

}
