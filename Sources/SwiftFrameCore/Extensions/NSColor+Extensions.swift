import AppKit
import Foundation

extension NSColor {

    convenience init(rgbaString: String) throws {
        let values = try parseCSSColorString(rgbaString)
        self.init(red: values.r, green: values.g, blue: values.b, alpha: values.a)
    }

    convenience init(hexString: String) throws {
        let hex = try stringToHex(hexString)

        let r = (hex >> 16) & 0xff
        let g = (hex >> 8) & 0xff
        let b = hex & 0xff

        guard r >= 0 && r <= 255, g >= 0 && g <= 255, b >= 0 && b <= 255 else {
            throw NSError(description: "Failed to create color from hex string \(hexString)")
        }

        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
    }

    var ky_hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        let hex = (Int(r * 255) << 16) + (Int(g * 255) << 8) + Int(b * 255)
        return String(format: "#%02lx%02lx%02lx", (hex >> 16) & 0xff, (hex >> 8) & 0xff, hex & 0xff)
    }

}

private func stringToHex(_ string: String) throws -> Int {
    guard
        let hexString = normalizeHexString(string),
        let hex = Int(hexString, radix: 16)
    else {
        throw NSError(description: "Failed to convert \(string) to hexadecimal number")
    }
    return hex
}

private func normalizeHexString(_ string: String) -> String? {
    let potentialHexString = string.hasPrefix("#") ? String(string[string.index(after: string.startIndex)...]) : string
    guard isValidHexString(potentialHexString) else {
        return nil
    }
    switch potentialHexString.count {
    case 3:
        var result = ""
        for character in potentialHexString {
            result += "\(character)\(character)"
        }
        return result
    case 6:
        return potentialHexString
    default:
        return nil
    }
}

func isValidHexString(_ string: String) -> Bool {
    CharacterSet(charactersIn: string).isSubset(of: CharacterSet(charactersIn: "#0123456789abcdefABCDEF"))
}

func isValidRGBAString(_ string: String) -> Bool {
    (try? NSRegularExpression.cssColorStringExpression().matches(string)) == true
}

func parseCSSColorString(_ string: String) throws -> (r: Double, g: Double, b: Double, a: Double) {
    let regularExpression = try NSRegularExpression.cssColorStringExpression()
    let stringRange = NSRange(location: 0, length: (string as NSString).length)
    let matches = regularExpression.matches(in: string, options: [], range: stringRange)

    guard matches.count == 1, let firstMatch = matches.first else {
        throw NSError(description: "String matched more than once")
    }

    let values: [Double] = try (0..<firstMatch.numberOfRanges).compactMap {
        let rangeBounds = firstMatch.range(at: $0)
        guard let range = Range(rangeBounds, in: string) else {
            throw NSError(description: "Could not make range in string")
        }
        let rangeString = String(string[range])
        if rangeString == string {
            return nil
        } else if let number = Double(string[range]) {
            return number
        } else {
            throw NSError(description: "Could not make number from \"\(rangeString)\"")
        }
    }

    guard 3 <= values.count, values.count <= 4 else {
        throw NSError(description: "Invalid number of RGB components")
    }

    return (
        clampedToRGBRangeIfNecessary(values[0]),
        clampedToRGBRangeIfNecessary(values[1]),
        clampedToRGBRangeIfNecessary(values[2]),
        clampedToRGBRangeIfNecessary(values[safe: 3] ?? 255)
    )
}

private func clampedToRGBRangeIfNecessary(_ value: CGFloat) -> CGFloat {
    let value = value.truncatingRemainder(dividingBy: 1) == 0
        ? (value / 255)
        : value
    return Clamped(initialValue: value, lowerBound: 0, upperBound: 1).wrappedValue
}
