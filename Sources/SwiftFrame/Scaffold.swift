import ArgumentParser
import Foundation
import SwiftFrameCore

struct Scaffold: ParsableCommand, VerbosePrintable {

    private static let defaultDevices = ["iPhoneX", "iPadPro12.9"]

    @Argument
    var locales: [String]

    @Option(help: "The root of the directory where you want to create the scaffold in", completion: .directory)
    var path: String?

    @Flag
    var lowercasedDirectories = false

    @Flag
    var noHelperFiles = false
    
    @Flag
    var verbose = false

    // Using this computed property to be able to provide a nice flag name but still have a value
    // to work with that is easily understandable semantically
    private var shouldCreateHelperFiles: Bool {
        !noHelperFiles
    }

    func run() throws {
        var numberOfCreatedDirectories = 0
        var numberOfCreatedFiles = 0

        let scaffoldRootURL = makeScaffoldRootURL()
        let stringsDirectoryURL = scaffoldRootURL.appendingPathComponent("Strings".ky_lowercasedIfNeeded(lowercasedDirectories))
        let screenshotsDirectoryURL = scaffoldRootURL.appendingPathComponent("Screenshots".ky_lowercasedIfNeeded(lowercasedDirectories))
        let templatesDirectoryURL = scaffoldRootURL.appendingPathComponent("Templates".ky_lowercasedIfNeeded(lowercasedDirectories))

        let directoriesToCreate = [
            scaffoldRootURL,
            stringsDirectoryURL,
            screenshotsDirectoryURL,
            templatesDirectoryURL,
        ]

        try directoriesToCreate.forEach { directory in
            printVerbose("Creating directory \(directory.path)")
            numberOfCreatedDirectories += 1
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        if shouldCreateHelperFiles {
            let configFileURL = scaffoldRootURL.appendingPathComponent("config.json")
            printVerbose("Creating empty config file \(configFileURL.path)")
            try FileManager.default.ky_createFile(atURL: configFileURL, contents: nil, attributes: nil)
            numberOfCreatedFiles += 1
        }

        try locales.forEach { locale in
            if shouldCreateHelperFiles {
                let localeStringsFileContents = "\"some string key\" = \"the corresponding translation\";"
                let localeStringsFileURL = stringsDirectoryURL.appendingPathComponent("\(locale).strings")
                printVerbose("Creating string file at \(localeStringsFileURL.path)")
                try FileManager.default.ky_writeToFile(localeStringsFileContents, destination: localeStringsFileURL)
                numberOfCreatedFiles += 1
            }

            try Scaffold.defaultDevices.forEach { deviceName in
                printVerbose("Creating screenshot directory for locale \(locale) and device \(deviceName)")
                numberOfCreatedDirectories += 1
                
                let localeScreenshotDirectoryURL = screenshotsDirectoryURL.appendingPathComponent(deviceName).appendingPathComponent(locale)
                try FileManager.default.createDirectory(at: localeScreenshotDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                
                if shouldCreateHelperFiles {
                    let markdownContents = "# \(deviceName) - \(locale)\n\nPlace your screenshots for \(deviceName) (\(locale)) in this folder\n" +
                    "Please make sure that all screenshots that represent the same screen have the same name for every locale."
                    try FileManager.default.ky_writeToFile(markdownContents, destination: localeScreenshotDirectoryURL.appendingPathComponent("README.md"))
                    numberOfCreatedFiles += 1
                }
            }
        }

        print("All done!")
        print("Created \(numberOfCreatedDirectories) directories".formattedGreen())
        print("Created \(numberOfCreatedFiles) files".formattedGreen())
    }

    private func makeScaffoldRootURL() -> URL {
        if let path = path {
            return URL(fileURLWithPath: path)
        } else {
            return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        }
    }

}

extension String {

    func ky_lowercasedIfNeeded(_ shouldUseLowercase: Bool) -> String {
        shouldUseLowercase ? self.lowercased() : self
    }

}
