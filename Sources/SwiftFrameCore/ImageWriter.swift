import AppKit
import Foundation

public final class ImageWriter {

    // MARK: - Exporting

    static func finish(
        context: CGContext,
        with outputPaths: [LocalURL],
        sliceSize: CGSize,
        outputWholeImage: Bool,
        locale: String,
        suffix: String,
        completion: @escaping (DispatchTimeoutResult) throws -> Void) throws
    {
        guard let finalImage = context.makeImage() else {
            throw NSError(description: "Could not render output image")
        }
        DispatchQueue(label: "image_writer_queue").async {
            do {
                try finishAsync(image: finalImage, with: outputPaths, sliceSize: sliceSize, outputWholeImage: outputWholeImage, locale: locale, suffix: suffix, completion: completion)
            } catch let error {
                print(error.localizedDescription.formattedRed())
                exit(1)
            }
        }
    }

    private static func finishAsync(
        image: CGImage,
        with outputPaths: [LocalURL],
        sliceSize: CGSize,
        outputWholeImage: Bool,
        locale: String,
        suffix: String,
        completion: @escaping (DispatchTimeoutResult) throws -> Void) throws
    {
        let slices = sliceImage(image, with: sliceSize)
        var slicesFinished = false
        var bigImageFinished = !outputWholeImage

        let workGroup = DispatchGroup()
        workGroup.enter()

        // Writing images asynchronously gave a big performance boost, what a surprise
        // Also, since we checked beforehand if the directory is writable, we can safely put of the rendering work to a different queue
        DispatchQueue(label: "slice_queue").async {
            do {
                try ImageWriter.write(images: slices, to: outputPaths, locale: locale, suffix: suffix)
                slicesFinished = true
                if slicesFinished && bigImageFinished {
                    workGroup.leave()
                }
            } catch let error {
                print(error.localizedDescription.formattedRed())
                exit(1)
            }
        }

        if outputWholeImage {
            DispatchQueue(label: "big_image_queue").async {
                do {
                    try outputPaths.forEach { try ImageWriter.write(image, to: $0.absoluteURL.appendingPathComponent(locale), fileName: "\(locale)-\(suffix)-big.png") }
                    bigImageFinished = true
                    if slicesFinished && bigImageFinished {
                        workGroup.leave()
                    }
                } catch let error {
                    print(error.localizedDescription.formattedRed())
                    exit(1)
                }
            }
        }

        let result = workGroup.wait(timeout: .now() + 5.00)
        try completion(result)
    }

    static func sliceImage(_ image: CGImage, with size: CGSize) -> [CGImage] {
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

    // MARK: - Writing Images

    static func write(images: [CGImage], to outputPaths: [LocalURL], locale: String, suffix: String) throws {
        try outputPaths.forEach { url in
            try images.enumerated().forEach { tuple in
                try write(tuple.element, to: url.absoluteString, locale: locale, deviceID: suffix, index: tuple.offset)
            }
        }
    }

    static func write(_ image: CGImage, to directoryPath: String, locale: String, deviceID: String, index: Int? = nil) throws {
        let fileName: String
        if let index = index {
            fileName = "\(locale)-\(deviceID)-\(index).png"
        } else {
            fileName = "\(locale)-\(deviceID).png"
        }
        let directory = URL(fileURLWithPath: directoryPath).appendingPathComponent(locale)
        try write(image, to: directory, fileName: fileName)
    }

    static func write(_ image: CGImage, to directoryPath: URL, fileName: String) throws {
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: .png, properties: [:]) else {
            throw NSError(description: "Failed to convert composed image to PNG")
        }

        try data.ky_write(to: directoryPath.appendingPathComponent(fileName))
    }

}
