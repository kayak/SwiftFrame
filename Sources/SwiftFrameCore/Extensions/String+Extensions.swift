import AppKit
import Foundation

extension String {

    public func formattedGreen() -> String {
        "\u{001B}[0;32m" + self + "\u{001B}[0;39m"
    }

    func formattedRed() -> String {
        "\u{001B}[0;31m" + self + "\u{001B}[0;39m"
    }

    public func ky_data(using encoding: String.Encoding) throws -> Data {
        guard let data = self.data(using: encoding, allowLossyConversion: false) else {
            throw NSError(description: "Could not create data from string")
        }
        return data
    }

}
