import Foundation

extension DispatchGroup {

    func ky_notifyOrDie(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], queue: DispatchQueue, execute work: @escaping () throws -> Void) {
        notify(qos: qos, flags: flags, queue: queue) {
            do {
                try work()
            } catch let error {
                print(CommandLineFormatter.formatError("\(error.localizedDescription)"))
                exit(1)
            }
        }
    }

}
