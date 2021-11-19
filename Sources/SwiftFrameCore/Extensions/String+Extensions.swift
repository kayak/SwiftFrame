import AppKit
import Foundation

extension String {

    public func formattedGreen() -> String {
        CommandLineFormatter.formatWithColorIfNeeded(self, color: .green)
    }

    func formattedRed() -> String {
        CommandLineFormatter.formatWithColorIfNeeded(self, color: .red)
    }

    public func ky_data(using encoding: String.Encoding = .utf8) throws -> Data {
        guard let data = self.data(using: encoding, allowLossyConversion: false) else {
            throw NSError(description: "Could not create data from string")
        }
        return data
    }

}
