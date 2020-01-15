import AppKit
import Foundation

public final class ImageWriter {

    // MARK: - Init

    public init() {}

    // MARK: - Writing Images

    public func write(_ image: CGImage, to directoryPath: String, deviceID: String, locale: String) throws {
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: .png, properties: [:]) else {
            throw NSError(description: "Failed to convert composed image to PNG")
        }
        let fileName = "\(locale)-\(deviceID).png"
        let url = URL(fileURLWithPath: directoryPath).appendingPathComponent(locale)

        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        try data.write(to: url.appendingPathComponent(fileName))
    }

}
