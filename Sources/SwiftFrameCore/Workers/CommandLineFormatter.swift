import Foundation

public final class CommandLineFormatter {

    // MARK: - Nested Types

    enum Color: Int {
        case red = 31
        case green = 32
        case yellow = 33
        case `default` = 39

        var escapeSequence: String {
            "\u{001B}[0;\(rawValue)m"
        }
    }

    fileprivate static let tabsString = String(repeating: " ", count: 4)

    // MARK: - Message Formatting

    public class func formatWarning(title: String = "WARNING", text: String) -> String {
        let message = "[\(title)] \(text)"
        return formatWithColorIfNeeded(message, color: .yellow)
    }

    public class func formatError(_ text: String) -> String {
        let message = "[ERROR] \(text)"
        return formatWithColorIfNeeded(message, color: .red)
    }

    public class func formatTimeMeasurement(_ text: String) -> String {
        let message = "[TIME] \(text)"
        return formatWithColorIfNeeded(message, color: .green)
    }

    class func formatWithColorIfNeeded(_ message: String, color: Color) -> String {
        if ConfigProcessor.shouldColorOutput {
            return message
        } else {
            return [color.escapeSequence, message, Color.default.escapeSequence].joined()
        }
    }

    // MARK: - Key-Value Formatting

    public class func printKeyValue(_ key: String, value: Any?, insetBy tabs: Int = 0) {
        guard let value = value else {
            return
        }
        print(CommandLineFormatter.formatKeyValue(key, value: value, insetBy: tabs))
    }

    private class func formatKeyValue(_ key: String, value: Any, insetBy tabs: Int = 0) -> String {
        let tabsString = String(repeating: CommandLineFormatter.tabsString, count: tabs)
        let formattedString = "\(key): \(String(describing: value).formattedGreen())"
        return tabsString + formattedString
    }

}

public func ky_print(_ objects: Any..., insetByTabs tabs: Int) {
    let tabsString = String(repeating: CommandLineFormatter.tabsString, count: tabs)
    let arguments = objects.count == 1
        ? String(describing: objects[0])
        : objects.map { String(describing: $0) }.joined(separator: " ")
    print(tabsString + arguments)
}
