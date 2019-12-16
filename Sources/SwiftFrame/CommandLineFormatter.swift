import Foundation

final class CommandLineFormatter {

    class func formatWarning(_ text: String) -> String {
        return "\u{001B}[0;33mWarning: \(text)\u{001B}[0;39m"
    }

    class func formatError(_ text: String) -> String {
        return "\u{001B}[0;31mError: \(text)\u{001B}[0;39m"
    }

    class func formatKeyValue(_ key: String, value: Any) -> String {
        return "\u{001B}[0;33m\(key):\u{001B}[0;39m \(value)"
    }

}
