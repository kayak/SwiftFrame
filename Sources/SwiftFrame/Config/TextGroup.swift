import Foundation

struct TextGroup: Codable, ConfigValidatable, Hashable {
    let identifier: String
    let maxFontSize: CGFloat

    func validate() throws {}

    func printSummary(insetByTabs tabs: Int) {
        print("Text group: \(identifier)", insetByTabs: tabs)
        print(CommandLineFormatter.formatKeyValue("Identifier", value: identifier, insetBy: tabs + 1))
        print(CommandLineFormatter.formatKeyValue("Max font size", value: maxFontSize, insetBy: tabs + 1))
    }
}
