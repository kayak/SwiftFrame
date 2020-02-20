import Foundation

struct PosixGroup {

    private static let canReadCodeSet = Set<Int16>([4,5,6,7])
    private static let canWriteCodeSet = Set<Int16>([2,3,6,7])
    private static let canExecuteCodeSet = Set<Int16>([1,3,5,7])

    let canWrite: Bool
    let canRead: Bool
    let canExecute: Bool

    init?(octalCode code: Int16) {
        guard 0..<8 ~= code else {
            return nil
        }

        canRead = PosixGroup.canReadCodeSet.contains(code)
        canWrite = PosixGroup.canWriteCodeSet.contains(code)
        canExecute = PosixGroup.canExecuteCodeSet.contains(code)
    }

}
