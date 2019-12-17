import AppKit
import Foundation

final class ImageWriter {

    func write(_ image: CGImage, to directoryPath: String, deviceID: String, locale: String) throws {
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: .png, properties: [:]) else {
            throw NSError(description: "Failed to convert composed image to PNG")
        }
        let fileName = "\(locale)-\(deviceID).png"
        let url = URL(fileURLWithPath: directoryPath).appendingPathComponent(fileName)
        try data.write(to: url)
    }

}
