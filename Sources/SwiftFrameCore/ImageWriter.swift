import AppKit
import Foundation

public final class ImageWriter {

    // MARK: - Init

    public init() {}

    // MARK: - Exporting

    func finish(context: CGContext, with outputPaths: [LocalURL], sliceSize: CGSize, outputWholeImage: Bool, locale: String, suffix: String) throws {
        guard let finalImage = context.makeImage() else {
            throw NSError(description: "Could not render output image")
        }
        let slices = sliceImage(finalImage, with: sliceSize)

        // Writing images asynchronously gave a big performance boost, what a surprise
        DispatchQueue(label: "slice_queue").async {
            do {
                try self.write(images: slices, to: outputPaths, locale: locale, suffix: suffix)
            } catch let error {
                print(error.localizedDescription.formattedRed())
                exit(1)
            }
        }

        if outputWholeImage {
            DispatchQueue(label: "big_image_queue").async {
                do {
                    try outputPaths.forEach { try self.write(finalImage, to: $0.absoluteURL.appendingPathComponent(locale), fileName: "\(locale)-\(suffix)-big.png") }
                } catch let error {
                    print(error.localizedDescription.formattedRed())
                    exit(1)
                }
            }
        }
    }

    func sliceImage(_ image: CGImage, with size: CGSize) -> [CGImage] {
        guard CGFloat(image.width).truncatingRemainder(dividingBy: size.width) == 0 else {
            print("Image width is not a multiple in width of desired size")
            return []
        }
        let numberOfSlices = image.width / Int(size.width)
        var croppedImages = [CGImage?]()

        for i in 0..<numberOfSlices {
            let rect = CGRect(x: size.width * CGFloat(i), y: 0, width: size.width, height: size.height)
            croppedImages.append(image.cropping(to: rect))
        }
        return croppedImages.compactMap { $0 }
    }

    func write(images: [CGImage], to outputPaths: [LocalURL], locale: String, suffix: String) throws {
        try outputPaths.forEach { url in
            try images.enumerated().forEach { tuple in
                try write(tuple.element, to: url.absoluteString, locale: locale, deviceID: suffix, index: tuple.offset)
            }
        }
    }

    // MARK: - Writing Images

    func write(_ image: CGImage, to directoryPath: String, locale: String, deviceID: String, index: Int? = nil) throws {
        let fileName: String
        if let index = index {
            fileName = "\(locale)-\(deviceID)-\(index).png"
        } else {
            fileName = "\(locale)-\(deviceID).png"
        }
        let directory = URL(fileURLWithPath: directoryPath).appendingPathComponent(locale)
        try write(image, to: directory, fileName: fileName)
    }

    func write(_ image: CGImage, to directoryPath: URL, fileName: String) throws {
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: .png, properties: [:]) else {
            throw NSError(description: "Failed to convert composed image to PNG")
        }

        try data.ky_write(to: directoryPath.appendingPathComponent(fileName))
    }

}
