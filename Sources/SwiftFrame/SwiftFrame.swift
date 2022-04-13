import ArgumentParser
import Foundation
import SwiftFrameCore

@main
struct SwiftFrame: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "swiftframe",
        abstract: "CLI application for speedy screenshot framing",
        version: "4.1.2",
        subcommands: [Render.self, Scaffold.self],
        defaultSubcommand: Render.self,
        helpNames: .shortAndLong
    )

}
