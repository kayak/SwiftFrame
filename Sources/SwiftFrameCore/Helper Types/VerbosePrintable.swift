import Foundation

public protocol VerbosePrintable {

    var verbose: Bool { get }

}

public extension VerbosePrintable {

    func printVerbose(_ args: Any...) {
        guard verbose else {
            return
        }

        let printString = args.map {
            String(describing: $0)
        }
        print(printString.joined(separator: " "))
    }

    func printElapsedTime(_ message: @autoclosure () -> String, startTime: CFAbsoluteTime) {
        let timeElapsed = Double(CFAbsoluteTimeGetCurrent() - startTime)
        let messageString = message() + " completed in \(String(format: "%.02f", timeElapsed))s"
        printVerbose(CommandLineFormatter.formatTimeMeasurement(messageString))
    }

    @inlinable func performAndPrintElapsedTime<T>(_ name: @autoclosure () -> String, work: () throws -> T) rethrows -> T {
        let startTime = CFAbsoluteTimeGetCurrent()
        let result = try work()
        printElapsedTime(name(), startTime: startTime)
        return result
    }

}
