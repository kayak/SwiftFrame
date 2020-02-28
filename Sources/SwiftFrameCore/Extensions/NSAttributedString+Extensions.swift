import Foundation

extension NSMutableAttributedString {

    // We have to parse and create the attributed string on the main thread since it uses WebKit according to this SO answer:
    // https://stackoverflow.com/questions/4217820/convert-html-to-nsattributedstring-in-ios/34190968#34190968
    static func ky_makeFromHTMLData(_ data: Data) -> NSMutableAttributedString? {
        if !Thread.isMainThread {
            return DispatchQueue.main.sync { ky_makeFromHTMLData(data) }
        }

        return NSMutableAttributedString(html: data, documentAttributes: nil)
    }

}
