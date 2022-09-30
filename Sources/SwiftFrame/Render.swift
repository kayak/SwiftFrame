import ArgumentParser
import Foundation
import SwiftFrameCore

struct Render: ParsableCommand {

    // MARK: - Arguments

    @Argument(
        help: "Read configuration values from the specified file",
        completion: .list(["config", "json", "yml", "yaml"])
    )
    var configFilePath: String

    // MARK: - Flags

    @Flag(
        name: .shortAndLong,
        help: "Prints additional information and lets you verify the config file before rendering"
    )
    var verbose = false

    @Flag(
        name: .long,
        help: "Pauses after parsing the config file to let you verify the contents"
    )
    var manualValidation = false

    @Flag(
        name: .long,
        help: "Outputs the whole image canvas into the output directories before slicing it up into the correct screenshot sizes. Helpful for troubleshooting"
    )
    var outputWholeImage = false

    @Flag(
        name: .long,
        help: "Disables any colored output. Useful when running in CI"
    )
    var noColorOutput = false

    @Flag(
        name: .long,
        help: "Disables clearing the output directories before writing images to them"
    )
    var noClearDirectories = false

    // MARK: - Run

    func run() throws {
        let configFileURL = URL(fileURLWithPath: configFilePath)

        do {
            let processor = try ConfigProcessor(
                configURL: configFileURL,
                verbose: verbose,
                shouldValidateManually: manualValidation,
                shouldOutputWholeImage: outputWholeImage,
                shouldClearDirectories: !noClearDirectories,
                shouldColorOutput: !noColorOutput
            )
            try processor.validate()
            try processor.run()
        } catch let error {
            ky_exitWithError(error, verbose: verbose)
        }
    }

}
