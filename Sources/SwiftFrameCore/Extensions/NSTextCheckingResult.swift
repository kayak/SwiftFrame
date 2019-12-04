import Foundation

extension NSTextCheckingResult {

    func substring(forRangeAt index: Int, in string: String) -> String {
        return (string as NSString).substring(with: range(at: index))
    }
    
}
