import Foundation

struct StringFilesContainer {

    static let goodData = ["\"someID\"": "\"Some interesting title\""]
    static let wrongKeyData = ["\"someIdentifier\"": "\"Some interesting title\""]

}

func writeStringFiles(for locales: [String]) throws {
    let fileContent = StringFilesContainer.goodData.makeStringFileContent()

    try locales.forEach {
        let filePath = URL(fileURLWithPath: "testing/strings/")
        try FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: true, attributes: nil)
        try fileContent.write(to: filePath.appendingPathComponent("\($0).strings"), atomically: false, encoding: .utf8)
    }
}

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
