import Foundation

extension DispatchQueue {

    func ky_asyncOrExit(_ block: @escaping () throws -> Void) {
        async {
            ky_executeSafely(block)
        }
    }

}
