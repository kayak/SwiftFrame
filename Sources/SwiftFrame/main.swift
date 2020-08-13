import Foundation
import ArgumentParser

struct SwiftFrame: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "swiftframe",
        abstract: "CLI application for speedy screenshot framing",
        version: "3.0.0",
        subcommands: [Render.self, GenerateConfig.self],
        defaultSubcommand: Render.self,
        helpNames: .shortAndLong)

}

SwiftFrame.main()
