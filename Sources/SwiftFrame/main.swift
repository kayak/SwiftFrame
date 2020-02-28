import AppKit
import CoreGraphics
import Foundation
import SwiftFrameCore

ky_executeSafely {
    let parseResult = try CommandParser().parse(CommandLine.arguments)

    let processor = try ConfigProcessor(filePath: parseResult.path, verbose: parseResult.verbose)
    try processor.validate()
    try processor.run()
}
