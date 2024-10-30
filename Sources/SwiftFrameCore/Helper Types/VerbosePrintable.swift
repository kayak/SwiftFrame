import Foundation

public protocol VerbosePrintable {

    var verbose: Bool { get }

}

extension VerbosePrintable {

    public func printVerbose(_ args: Any...) {
        guard verbose else {
            return
        }

        let printString = args.map {
            String(describing: $0)
        }
        print(printString.joined(separator: " "))
    }

    public func printElapsedTime(_ message: @autoclosure () -> String, startTime: CFAbsoluteTime) {
        let timeElapsed = Double(CFAbsoluteTimeGetCurrent() - startTime)
        let messageString = message() + " completed in \(String(format: "%.02f", timeElapsed))s"
        printVerbose(CommandLineFormatter.formatTimeMeasurement(messageString))
    }

}
