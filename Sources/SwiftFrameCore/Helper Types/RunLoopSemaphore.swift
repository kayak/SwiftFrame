import Foundation

/// A replacement for `DispatchSemaphore` in case you want to wait (block) on a thread, but signalling is
/// occuring from the same (already blocked) thread. (e.g. waiting on main and signalling from main as well)
/// See: http://stackoverflow.com/questions/17920169/how-to-wait-for-method-that-has-completion-block-all-on-main-thread
public class RunLoopSemaphore {

    var signalsRemaining: Int?

    private var isRunLoopNested = false
    private var isOperationCompleted = false

    public init(count: Int? = nil) {
        signalsRemaining = count
    }

    public func signal() {
        incrementCounter()
        guard !isOperationCompleted else {
            return
        }
        isOperationCompleted = signalsRemaining == 0

        if isRunLoopNested && (signalsRemaining ?? 0) == 0 {
            CFRunLoopStop(CFRunLoopGetCurrent())
        }
    }

    public func wait(timeout: DispatchTime? = nil) {
        if let timeout = timeout {
            DispatchQueue.main.asyncAfter(deadline: timeout) { [weak self] in
                self?.signal()
            }
        }
        if !isOperationCompleted {
            isRunLoopNested = true
            CFRunLoopRun()
            isRunLoopNested = false
        }
    }

    private func incrementCounter() {
        if let signals = signalsRemaining {
            self.signalsRemaining = signals - 1
        }
    }

}
