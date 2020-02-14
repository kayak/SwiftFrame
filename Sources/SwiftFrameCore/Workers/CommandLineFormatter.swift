import Foundation

public final class CommandLineFormatter {

    public class func formatWarning(_ text: String) -> String {
        return "\u{001B}[0;33mWarning: \(text)\u{001B}[0;39m"
    }

    public class func formatError(_ text: String) -> String {
        return "\u{001B}[0;31mError: \(text)\u{001B}[0;39m"
    }

    private static func formatKeyValue(_ key: String, value: Any, insetBy tabs: Int = 0) -> String {
        let tabsString = String(repeating: " ", count: 4 * tabs)
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

public func print(_ any: Any..., insetByTabs tabs: Int) {
    let tabsString = String(repeating: " ", count: 4 * tabs)
    let arguments = any.count == 1
        ? String(describing: any[0])
        : any.map { String(describing: $0) }.joined(separator: " ")
    Swift.print(tabsString + arguments)
}
