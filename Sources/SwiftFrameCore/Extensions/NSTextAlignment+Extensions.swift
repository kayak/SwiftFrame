import AppKit

extension NSTextAlignment {

    var cssName: String {
        switch self {
        case .left:
            return "left"
        case .right:
            return "right"
        case .center:
            return "center"
        case .justified:
            return "justify"
        default:
            return "inherit"
        }
    }

}
