import Foundation

final class CommandLineFormatter {

    class func formatWarning(_ text: String) -> String {
        return "\u{001B}[0;33mWarning: \(text)\u{001B}[0;39m"
    }

    class func formatError(_ text: String) -> String {
        return "\u{001B}[0;31mError: \(text)\u{001B}[0;39m"
    }

    class func formatKeyValue(_ key: String, value: Any, insetBy tabs: Int = 0) -> String {
        let tabsString = String(repeating: " ", count: 4 * tabs)
        let formattedString = "\(key): \(String(describing: value).formattedGreen())"
        return tabsString + formattedString
    }

}

extension String {
    func formattedGreen() -> String {
        "\u{001B}[0;32m" + self + "\u{001B}[0;39m"
    }
}
