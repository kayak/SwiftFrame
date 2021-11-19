import Foundation

extension NSMutableAttributedString {

    // We have to parse and create the attributed string on the main thread since it uses WebKit according to this SO answer:
    // https://stackoverflow.com/questions/4217820/convert-html-to-nsattributedstring-in-ios/34190968#34190968
    static func ky_makeFromHTMLData(_ data: Data) throws -> NSMutableAttributedString {
        guard Thread.current.isMainThread else {
            throw NSError(description: "Attributed string parsing has to be done on the main thread")
        }
        let string = NSMutableAttributedString(
            html: data,
            options: [.characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil
        )
        if let string = string {
            return string
        } else {
            throw NSError(description: "Could not parse HTML string")
        }
    }

}
