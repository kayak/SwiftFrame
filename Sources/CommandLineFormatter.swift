import Foundation

final class CommandLineFormatter {

    func formatWarning(_ text: String) -> String {
        return "\u{001B}[0;33mWarning: \(text)\u{001B}[0;39m"
    }

    func formatError(_ text: String) -> String {
        return "\u{001B}[0;31mError: \(text)\u{001B}[0;39m"
    }

}
