import Foundation

@propertyWrapper struct Clamped<C: Comparable> {

    let lowerBound: C
    let upperBound: C

    private var _wrappedValue: C

    var wrappedValue: C {
        get { _wrappedValue }
        set { _wrappedValue = Self.clamped(newValue, lowerBound: lowerBound, upperBound: upperBound) }
    }

    init(initialValue: C, lowerBound: C, upperBound: C) {
        guard lowerBound < upperBound else {
            preconditionFailure("Lower bound \(lowerBound) has to actually be lower than upper bound \(upperBound)")
        }
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self._wrappedValue = Self.clamped(initialValue, lowerBound: lowerBound, upperBound: upperBound)
    }

    private static func clamped(_ value: C, lowerBound: C, upperBound: C) -> C {
        if value < lowerBound {
            return lowerBound
        } else if upperBound < value {
            return upperBound
        } else {
            return value
        }
    }

}
