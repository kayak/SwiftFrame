import Foundation
import SPMUtility
import Yams

public class CommandParser {

    public struct Result {

        public enum ConfigFormat {
            case json
            case yaml
        }

        public let verbose: Bool
        public let path: String
        public let format: ConfigFormat

    }

    private let parser: ArgumentParser
    private let configFlag: OptionArgument<String>
    private let verboseFlag: OptionArgument<Bool>
    private let configFormatFlag: OptionArgument<String>

    public init() {
        parser = ArgumentParser(
            commandName: nil,
            usage: "[-c path] [-v] [-f format]",
            overview: "Overlay screenshots from your app with a template file and text and render them",
            seeAlso: nil)
        configFlag = parser.add(
            option: "--config",
            shortName: "-c",
            kind: String.self,
            usage: "Read configuration values from the specified file",
            completion: .filename)
        verboseFlag = parser.add(
            option: "--verbose",
            shortName: "-v",
            kind: Bool.self,
            usage: "Prints additional information and lets you verify the config file before rendering",
            completion: .unspecified)
        configFormatFlag = parser.add(
            option: "--format",
            shortName: "-f",
            kind: String.self,
            usage: "Specifies the format of the config file. \"json\" or \"yaml\" are allowed",
            completion: .unspecified)
    }

    public func parse(_ arguments: [String]) throws -> Result {
        let cleanedArgs: [String] = arguments.first?.hasSuffix("swiftframe") ?? false
            ? Array(arguments.dropFirst())
            : arguments
        let result = try parser.parse(cleanedArgs)

        let verbose = result.get(verboseFlag) ?? false
        let format = result.get(configFormatFlag)

        guard let path = result.get(configFlag) else {
            throw NSError(description: "No config file path was specified")
        }
        return Result(verbose: verbose, path: path, format: formatFromArgument(format))
    }

    private func formatFromArgument(_ argument: String?) -> Result.ConfigFormat {
        guard let argument = argument else {
            return .json
        }

        switch argument {
        case "json", "JSON":
            return .json
        case "yaml", "YAML":
            return .yaml
        default:
            print(CommandLineFormatter.formatWarning("Unknown config format specified, defaulting to JSON"))
            return .json
        }
    }

}
