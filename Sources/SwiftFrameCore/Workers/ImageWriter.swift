import AppKit
import Foundation

public final class ImageWriter {

    // MARK: - Exporting

    static func finish(
        context: CGContext,
        with outputPaths: [FileURL],
        sliceSize: CGSize,
        outputWholeImage: Bool,
        locale: String,
        suffix: String,
        format: FileFormat,
        completion: @escaping () throws -> Void) throws {
        guard let image = context.makeImage() else {
            throw NSError(description: "Could not render output image")
        }
        DispatchQueue.global().ky_asyncThrowing {
            let slices = sliceImage(image, with: sliceSize)
            var slicesFinished = false
            var bigImageFinished = !outputWholeImage

            let workGroup = DispatchGroup()
            workGroup.enter()

            // Writing images asynchronously gave a big performance boost, what a surprise
            // Also, since we checked beforehand if the directory is writable, we can safely put of the rendering work to a different queue
            DispatchQueue.global().ky_asyncThrowing {
                try ImageWriter.write(images: slices, to: outputPaths, locale: locale, suffix: suffix, format: format)
                slicesFinished = true
                if slicesFinished && bigImageFinished {
                    workGroup.leave()
                }
            }

            if outputWholeImage {
                DispatchQueue.global().ky_asyncThrowing {
                    try outputPaths.forEach {
                        try ImageWriter.write(image, to: $0.absoluteURL.appendingPathComponent(locale), fileName: "\(locale)-\(suffix)-big", format: format)
                    }
                    bigImageFinished = true
                    if slicesFinished && bigImageFinished {
                        workGroup.leave()
                    }
                }
            }

            _ = workGroup.wait(timeout: .now() + 5.00)
            try completion()
        }
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

    static func write(images: [CGImage], to outputPaths: [FileURL], locale: String, suffix: String, format: FileFormat) throws {
        try outputPaths.forEach { url in
            try images.enumerated().forEach { tuple in
                try write(tuple.element, to: url.absoluteURL.path, locale: locale, deviceID: suffix, index: tuple.offset, format: format)
            }
        }
    }

    static func write(_ image: CGImage, to directoryPath: String, locale: String, deviceID: String, index: Int? = nil, format: FileFormat) throws {
        let fileName: String
        if let index = index {
            fileName = "\(locale)-\(deviceID)-\(index)"
        } else {
            fileName = "\(locale)-\(deviceID)"
        }
        let directory = URL(fileURLWithPath: directoryPath).appendingPathComponent(locale)
        try write(image, to: directory, fileName: fileName, format: format)
    }

    static func write(_ image: CGImage, to directoryPath: URL, fileName: String, format: FileFormat) throws {
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: format, properties: [:]) else {
            throw NSError(description: "Failed to convert composed image to PNG")
        }

        let targetURL = directoryPath
            .appendingPathComponent(fileName)
            .appendingPathExtension(format.fileExtension)
        try data.ky_write(to: targetURL, options: .atomicWrite)
    }

}
