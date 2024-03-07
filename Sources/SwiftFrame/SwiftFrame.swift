import ArgumentParser
import Foundation
import SwiftFrameCore

@main
struct SwiftFrame: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "swiftframe",
        abstract: "CLI application for speedy screenshot framing",
        version: "6.0.0",
        subcommands: [Render.self, Scaffold.self],
        defaultSubcommand: Render.self,
        helpNames: .shortAndLong
    )

}
