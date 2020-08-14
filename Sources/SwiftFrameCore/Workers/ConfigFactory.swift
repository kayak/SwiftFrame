import Foundation
import Yams

public struct ConfigFactory {

    public static func createConfig(format: ConfigFileFormat) throws -> Data {
        let config = ConfigData(
            textGroups: [.makeTemplate(), .makeTemplate()],
            stringsPath: .makeTemplate(),
            maxFontSize: 120,
            outputPaths: [.makeTemplate()],
            fontSource: .filePath("/System/Library/Fonts/HelveticaNeue.ttc"),
            textColorSource: try .init(hexString: "#FFF"),
            outputFormat: .png,
            clearDirectories: true,
            outputWholeImage: true,
            deviceData: [.makeTemplate(), .makeTemplate()],
            localesRegex: nil
        )

        return try format.encoder.encode(config)
    }

}
