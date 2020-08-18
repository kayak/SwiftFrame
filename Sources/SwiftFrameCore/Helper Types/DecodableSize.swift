import Foundation

/// Wrapper struct used to work around weird decoding behaviour of `CGSize`
struct DecodableSize: Codable {

    let width: CGFloat
    let height: CGFloat

    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }

}
