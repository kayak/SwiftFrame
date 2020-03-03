import Foundation

/// A replacement for `DispatchSemaphore` in case you want to wait (block) on a thread, but signalling is
/// occuring from the same (already blocked) thread. (e.g. waiting on main and signalling from main as well)
/// See: http://stackoverflow.com/questions/17920169/how-to-wait-for-method-that-has-completion-block-all-on-main-thread
public class RunLoopSemaphore {

    private var isRunLoopNested = false
    private var isOperationCompleted = false

    public init() {}

    public func signal() {
        guard !isOperationCompleted else {
            return
        }
        isOperationCompleted = true

        if isRunLoopNested {
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

}
