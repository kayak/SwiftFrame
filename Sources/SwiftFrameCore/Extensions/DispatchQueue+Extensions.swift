import Foundation

extension DispatchQueue {

    func ky_asyncOrExit(verbose: Bool = false, _ block: @escaping () throws -> Void) {
        async {
            ky_executeOrExit(verbose: verbose, block)
        }
    }

}
