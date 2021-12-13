import ArgumentParser
import Foundation
import SwiftFrameCore

struct SwiftFrame: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "swiftframe",
        abstract: "CLI application for speedy screenshot framing",
        version: "4.0.1",
		subcommands: [Render.self, Scaffold.self],
		defaultSubcommand: Render.self,
        helpNames: .shortAndLong
    )

}

SwiftFrame.main()
