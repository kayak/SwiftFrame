import AppKit
import Foundation

final class ImageWriter {

    // MARK: - Exporting

    static func finish(
        context: GraphicsContext,
        with outputPaths: [FileURL],
        sliceSize: CGSize,
        gapWidth: Int,
        outputWholeImage: Bool,
        locale: String,
        suffixes: [String],
        format: FileFormat
    ) throws {
        guard let image = context.cg.makeImage() else {
            throw NSError(description: "Could not render output image")
        }
        let slices = try sliceImage(image, with: sliceSize, gapWidth: gapWidth)
        let fileNameConfiguration = OutputConfiguration(
            outputPaths: outputPaths,
            locale: locale,
            suffixes: suffixes,
            format: format
        )

        let workGroup = DispatchGroup()

        // Writing images asynchronously gave a big performance boost, what a surprise
        // Also, since we checked beforehand if the directory is writable, we can safely put of the rendering work to a different queue
        workGroup.enter()
        DispatchQueue.global(qos: .userInitiated).ky_asyncOrExit {
            try ImageWriter.writeSlices(slices, with: fileNameConfiguration)
            workGroup.leave()
        }

        if outputWholeImage {
            workGroup.enter()
            DispatchQueue.global(qos: .userInitiated).ky_asyncOrExit {
                try ImageWriter.writeBigImage(image, with: fileNameConfiguration)
                workGroup.leave()
            }
        }

        workGroup.wait()
    }

    static func sliceImage(_ image: CGImage, with size: CGSize, gapWidth: Int) throws -> [CGImage] {
        let numberOfSlices = image.width / Int(size.width)
        var croppedImages: [CGImage] = []

        for i in 0 ..< numberOfSlices {
            let rect = CGRect(x: (size.width * CGFloat(i)) + (CGFloat(gapWidth) * CGFloat(i)), y: 0, width: size.width, height: size.height)
            image.cropping(to: rect).flatMap { croppedImages.append($0) }
        }

        guard croppedImages.count == numberOfSlices else {
            throw NSError(description: "Actual number of cropped images was smaller than target number")
        }
        return croppedImages
    }

    // MARK: - Writing Images

    static func writeSlices(_ images: [CGImage], with configuration: OutputConfiguration) throws {
        DispatchQueue.concurrentPerform(iterations: images.count) { index in
            ky_executeOrExit {
                let image = images[index]
                let outputPaths = configuration.makeOutputPaths(for: index)
                try writeImage(image, to: outputPaths, format: configuration.format)
            }
        }
    }

    static func writeBigImage(_ image: CGImage, with configuration: OutputConfiguration) throws {
        let outputPaths = configuration.makeBigImageOutputPaths()
        try writeImage(image, to: outputPaths, format: configuration.format)
    }

    static func writeImage(_ image: CGImage, to urls: [URL], format: FileFormat) throws {
        let rep = NSBitmapImageRep(cgImage: image)
        guard let data = rep.representation(using: format, properties: [:]) else {
            throw NSError(description: "Failed to convert image to \(format.fileExtension.uppercased())")
        }

        for url in urls {
            try data.ky_write(to: url, options: .atomicWrite)
        }
    }

}

// MARK: - OutputConfiguration

extension ImageWriter {

    struct OutputConfiguration {

        // MARK: - Properties

        let outputPaths: [FileURL]
        let locale: String
        let suffixes: [String]
        let format: FileFormat

        // MARK: - Methods

        func makeBigImageOutputPaths() -> [URL] {
            var urls: [URL] = []
            for basePath in makeBasePaths() {
                for suffix in suffixes {
                    let url = basePath.appendingPathComponent("\(locale)-\(suffix)-big").appendingPathExtension(format.fileExtension)
                    urls.append(url)
                }
            }
            return urls
        }

        func makeOutputPaths(for sliceIndex: Int) -> [URL] {
            var urls: [URL] = []
            for basePath in makeBasePaths() {
                for suffix in suffixes {
                    let url = basePath.appendingPathComponent("\(locale)-\(suffix)-\(sliceIndex)").appendingPathExtension(
                        format.fileExtension
                    )
                    urls.append(url)
                }
            }
            return urls
        }

        private func makeBasePaths() -> [URL] {
            outputPaths.map { $0.absoluteURL.appendingPathComponent(locale) }
        }

    }

}
