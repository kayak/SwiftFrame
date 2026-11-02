import CoreGraphics

extension CGImage {

    /// The actual pixel size of the image.
    ///
    /// When dealing with screenshots from an iOS device for example, the `size` property of `NSBitmapImageRep`
    /// is scaled down by the UIKit scale of the device, so use this property for pixel calculations.
    var ky_nativeSize: CGSize {
        CGSize(width: width, height: height)
    }

    var ky_nativeRect: CGRect {
        CGRect(origin: .zero, size: ky_nativeSize)
    }

}
