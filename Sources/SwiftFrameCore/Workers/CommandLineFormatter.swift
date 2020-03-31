import Foundation

public final class CommandLineFormatter {

    fileprivate static let tabsString = String(repeating: " ", count: 4)

    public class func formatWarning(title: String = "Warning", text: String) -> String {
        "\u{001B}[0;33m[\(title.uppercased())] \(text)\u{001B}[0;39m"
    }

    public class func formatError(_ text: String) -> String {
        "\u{001B}[0;31m[ERROR] \(text)\u{001B}[0;39m"
    }

    private static func formatKeyValue(_ key: String, value: Any, insetBy tabs: Int = 0) -> String {
        let tabsString = String(repeating: CommandLineFormatter.tabsString, count: tabs)
        let formattedString = "\(key): \(String(describing: value).formattedGreen())"
        return tabsString + formattedString
    }

    public class func printKeyValue(_ key: String, value: Any?, insetBy tabs: Int = 0) {
        guard let value = value else {
            return
        }
        print(CommandLineFormatter.formatKeyValue(key, value: value, insetBy: tabs))
    }

}

public func ky_print(_ objects: Any..., insetByTabs tabs: Int) {
    let tabsString = String(repeating: CommandLineFormatter.tabsString, count: tabs)
    let arguments = objects.count == 1
        ? String(describing: objects[0])
        : objects.map { String(describing: $0) }.joined(separator: " ")
    print(tabsString + arguments)
}
