import Foundation

// MARK: - CGSize

extension CGSize {
    static let square100Pixels: CGSize = CGSize(width: 100, height: 100)
}

// MARK: - Dictionary

extension Dictionary where Value == String, Key == String {

    func makeStringFileContent() -> String {
        let strings: [String] = keys.sorted().compactMap {
            guard let element = self[$0] else {
                return nil
            }
            return [$0, element + ";"].joined(separator: " = ")
        }
        return strings.joined(separator: "\n")
    }

}
