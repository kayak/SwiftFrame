import AppKit
import CoreGraphics
import Foundation

do {
    let options = CommandLineOptions()
    try options.parse(arguments: CommandLine.arguments)

    guard !options.help.isSpecified else {
        print(options.summarizeUsage())
        exit(0)
    }

    guard let configPath = options.configPath.arguments.first else {
        throw NSError(description: "Please specify a config file path")
    }
    let configURL = URL(fileURLWithPath: configPath)
    let data = try Data(contentsOf: configURL)
    
    let config = try JSONDecoder().decode(ConfigFile.self, from: data)
    let verbose = options.verbose.isSpecified

    try config.validate()

    if verbose {
        config.printSummary(insetByTabs: 0)
        print("Press return key to continue")
        _ = readLine()
    }

    print("Parsed and validated config file")

    let writer = ImageWriter()

    try config.deviceData.forEach { device in
        try device.screenshots.forEach { locale, imageDict in
            print("Rendering screenshots for \"\(locale)\" for device \(device.outputSuffix)")

            let composer = try ImageComposer(device.templateImage)

            try device.screenshotData.forEach { data in
                guard let image = imageDict[data.screenshotName] else {
                    throw NSError(description: "Screenshot named \(data.screenshotName) not found in folder \"\(locale)\"")
                }
                try composer.add(screenshot: image, with: data)

                if verbose {
                    print("Rendered screenshot \(data.screenshotName)".formattedGreen(), insetByTabs: 1)
                }
            }

            try composer.addTemplateImage()

            let constructedTitles: [AssociatedString] = try device.textData.map {
                guard let title = config.titles[locale]?[$0.titleIdentifier] else {
                    throw NSError(description: "Title with key \"\($0.titleIdentifier)\" not found in string file \"\(locale)\"")
                }
                return (title, $0)
            }

            let maxFontSizeByGroup = config.textGroups.reduce(into: [String: CGFloat]()) { dictionary, group in
                let strings = constructedTitles.filter({ $0.data.groupIdentifier == group.identifier })
                dictionary[group.identifier] = group.sharedFontSize(with: strings, globalFont: config.font, globalMaxSize: config.maxFontSize)
            }

            try constructedTitles.forEach {
                if let sharedSize = maxFontSizeByGroup[safe: $0.data.groupIdentifier] {
                    // Can use fixed font size since common maximum has already been calculated
                    composer.add(
                        title: $0.string,
                        font: $0.data.customFont ?? config.font,
                        color: $0.data.textColorOverride ?? config.textColor,
                        fixedFontSize: sharedSize,
                        textData: $0.data)
                } else {
                    let renderedFontsize = try composer.add(
                        title: $0.string,
                        font: $0.data.customFont ?? config.font,
                        color: $0.data.textColorOverride ?? config.textColor,
                        maxFontSize: config.maxFontSize,
                        textData: $0.data)

                    if verbose {
                        print("Rendered title with identifier \"\($0.data.titleIdentifier)\" with font size \(Int(renderedFontsize))")
                    }
                }
            }

            if let finalImage = composer.renderFinalImage() {
                guard let size = imageDict.first?.value.nativeSize else {
                    throw NSError(description: "No screenshots supplied, so it's impossible to slice into the correct size")
                }
                let slices = composer.slice(image: finalImage, with: size)
                try config.outputPaths.forEach { url in
                    try slices.enumerated().forEach { (offset, image) in
                        try writer.write(image, to: url.absoluteString, deviceID: device.outputSuffix + "-\(offset)", locale: locale)
                    }

                    if config.outputWholeImage {
                        try writer.write(finalImage, to: url.absoluteString, deviceID: device.outputSuffix + "-big", locale: locale)
                    }
                }
            } else {
                throw NSError(description: "Could not create final image")
            }
        }
    }

    print("Done!".formattedGreen())

} catch let error as NSError {
    // The cast to `NSError` is mandatory here or otherwise the program will die with a segfault when built through `xcodebuild`.
    // Interestingly, the same does not happen when building with Xcode directly.
    print(CommandLineFormatter.formatError("\(error.localizedDescription)"))
    exit(1)
}
