import AppKit
import Foundation

public final class ImageWriter {

    // MARK: - Exporting

    static func finish(
        context: GraphicsContext,
        with outputPaths: [FileURL],
        sliceSize: CGSize,
        gapWidth: Int,
        outputWholeImage: Bool,
        locale: String,
        suffixes: [String],
        format: FileFormat) throws
    {
        guard let image = context.cg.makeImage() else {
            throw NSError(description: "Could not render output image")
        }
        let slices = try sliceImage(image, with: sliceSize, gapWidth: gapWidth)

        let workGroup = DispatchGroup()

        suffixes.forEach { suffix in
            // Writing images asynchronously gave a big performance boost, what a surprise
            // Also, since we checked beforehand if the directory is writable, we can safely put of the rendering work to a different queue
            workGroup.enter()
            DispatchQueue.global(qos: .userInitiated).ky_asyncOrExit {
                try ImageWriter.write(images: slices, to: outputPaths, locale: locale, suffix: suffix, format: format)
                workGroup.leave()
            }

            if outputWholeImage {
                workGroup.enter()
                DispatchQueue.global(qos: .userInitiated).ky_asyncOrExit {
                    try outputPaths.forEach {
                        try ImageWriter.write(image, to: $0.absoluteURL.appendingPathComponent(locale), fileName: "\(locale)-\(suffix)-big", format: format)
                    }
                    workGroup.leave()
                }
            }
        }

        workGroup.wait()
    }

    static func sliceImage(_ image: CGImage, with size: CGSize, gapWidth: Int) throws -> [CGImage] {
        let numberOfSlices = image.width / Int(size.width)
        var croppedImages = [CGImage]()

        for i in 0..<numberOfSlices {
            let rect = CGRect(x: (size.width * CGFloat(i)) + (CGFloat(gapWidth) * CGFloat(i)), y: 0, width: size.width, height: size.height)
            image.cropping(to: rect).flatMap { croppedImages.append($0) }
        }

        guard croppedImages.count == numberOfSlices else {
            throw NSError(description: "Actual number of cropped images was smaller than target number")
        }
        return croppedImages
    }

    // MARK: - Writing Images

    static func write(images: [CGImage], to outputPaths: [FileURL], locale: String, suffix: String, format: FileFormat) throws {
        try outputPaths.forEach { url in
            try images.enumerated().forEach { tuple in
                try write(tuple.element, to: url.path, locale: locale, deviceID: suffix, index: tuple.offset, format: format)
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
