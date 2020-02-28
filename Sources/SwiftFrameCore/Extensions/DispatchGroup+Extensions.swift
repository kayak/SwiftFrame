import Foundation

extension DispatchGroup {

    func ky_notifyOrExit(qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = [], queue: DispatchQueue, execute work: @escaping () throws -> Void) {
        notify(qos: qos, flags: flags, queue: queue) {
            ky_executeSafely(work)
        }
    }

}
