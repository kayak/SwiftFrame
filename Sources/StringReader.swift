import Foundation

final class StringReader {

    func read(from path: String) throws -> [String] {
        var strings = [String]()
        (try content(ofFileAtPath: path)).enumerateLines { line, _ in
            guard !line.isEmpty else {
                return
            }
            strings.append(line.replacingOccurrences(of: "\\n", with: "\n"))
        }
        return strings
    }

    private func content(ofFileAtPath path: String) throws -> String {
        do {
            return try String(contentsOfFile: path)
        } catch {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            guard let content = string(from: data, encodings: [.utf8, .utf16]) else {
                throw NSError(description: "Could not read strings from \(path)")
            }
            return content
        }
    }

    private func string(from data: Data, encodings: [String.Encoding]) -> String? {
        for encoding in encodings {
            if let string = String(data: data, encoding: encoding) {
                return string
            }
        }
        return nil
    }

}
