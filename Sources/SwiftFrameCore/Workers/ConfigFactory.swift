import Foundation
import Yams

struct BareboneConfigData: Config, Encodable {

    let stringsPath: FileURL
    let maxFontSize: CGFloat
    let outputPaths: [FileURL]
    let textColorSource: ColorSource
    let outputFormat: FileFormat
    let localesRegex: String?

    enum CodingKeys: String, CodingKey {
        case stringsPath
        case maxFontSize
        case outputPaths
        case textColorSource = "textColor"
        case outputFormat = "format"
        case localesRegex = "locales"
    }

}

public struct ConfigFactory {

    public static func createConfig(format: ConfigFileFormat) throws -> Data {

        let configData = BareboneConfigData(
            stringsPath: FileURL(path: "test"),
            maxFontSize: 120,
            outputPaths: [FileURL(path: "Example/")],
            textColorSource: try ColorSource(hexString: "#FFF"),
            outputFormat: .jpeg,
            localesRegex: nil)

        return try format.encoder.encode(configData)
    }

}
