import AppKit
import Foundation

public final class ImageWriter {

    // MARK: - Init

    public init() {}

    // MARK: - Writing Images

    public func write(_ image: CGImage, to directoryPath: String, locale: String, deviceID: String, index: Int? = nil) throws {
        let fileName: String
        if let index = index {
            fileName = "\(locale)-\(deviceID)-\(index).png"
        } else {
            fileName = "\(locale)-\(deviceID).png"
        }
        let directory = URL(fileURLWithPath: directoryPath).appendingPathComponent(locale)
        try write(image, to: directory, fileName: fileName)
    }

    public func write(_ image: CGImage, to directoryPath: URL, fileName: String) throws {
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: .png, properties: [:]) else {
            throw NSError(description: "Failed to convert composed image to PNG")
        }

        try data.ky_write(to: directoryPath.appendingPathComponent(fileName))
    }

}
