import Foundation
import SPMUtility

public class CommandParser {

    public struct Result {
        public let verbose: Bool
        public let path: String
    }

    private static let parser = ArgumentParser(
        commandName: nil,
        usage: "[-c path] [-v]",
        overview: "Overlay screenshots from your app with a template file and text and render them",
        seeAlso: nil)

    private static var configFlag: OptionArgument<String> {
        parser.add(
            option: "--config",
            shortName: "-c",
            kind: String.self,
            usage: "Read configuration values from the specified file",
            completion: .filename)
    }

    private static var verboseFlag: OptionArgument<Bool> {
        parser.add(
            option: "--verbose",
            shortName: "-v",
            kind: Bool.self,
            usage: "Prints additional information and lets you verify the config file before rendering",
            completion: .unspecified)
    }

    public static func parse(_ arguments: [String]) throws -> Result {
        print(arguments)
        let cleanedArgs: [String] = arguments.first?.hasSuffix("swiftframe") ?? false
            ? Array(arguments.dropFirst())
            : arguments
        let result = try parser.parse(cleanedArgs)
        let verbose = result.get(verboseFlag) ?? false
        guard let path = result.get(configFlag) else {
            throw NSError(description: "No config file path was specified")
        }
        return Result(verbose: verbose, path: path)
    }

}
