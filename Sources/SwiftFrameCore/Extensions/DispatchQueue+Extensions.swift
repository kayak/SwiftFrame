import Foundation

extension DispatchQueue {

    func ky_asyncOrExit(_ block: @escaping () throws -> Void) {
        async {
            do {
                try block()
            } catch let error {
                print(CommandLineFormatter.formatError("\(error.localizedDescription)"))
                exit(1)
            }
        }
    }

}
