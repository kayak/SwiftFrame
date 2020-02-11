import AppKit
import Foundation
import SwiftFrameCore

extension TextData {

    static var goodData: Self {
        TextData(
            titleIdentifier: "someId",
            textAlignment: .center,
            topLeft: Point(x: 10, y: 5),
            bottomRight: Point(x: 15, y: 20))
    }

    static var invalidData: Self {
        TextData(
            titleIdentifier: "someId",
            textAlignment: .center,
            topLeft: Point(x: 10, y: 5),
            bottomRight: Point(x: 8, y: 20))
    }

    static var invertedData: Self {
        TextData(
            titleIdentifier: "someId",
            textAlignment: .center,
            topLeft: Point(x: 10, y: 20),
            bottomRight: Point(x: 15, y: 5))
    }

}
