import AppKit
import Foundation
@testable import SwiftFrameCore

extension TextData {

    static var goodData: Self {
        TextData(
            titleIdentifier: "someId",
            textAlignment: .center,
            maxFontSizeOverride: nil,
            fontOverride: nil,
            textColorOverrideString: nil,
            groupIdentifier: nil,
            topLeft: Point(x: 10, y: 5),
            bottomRight: Point(x: 15, y: 20),
            textColorOverride: nil)
    }

    static var invalidData: Self {
        TextData(
            titleIdentifier: "someId",
            textAlignment: .center,
            maxFontSizeOverride: nil,
            fontOverride: nil,
            textColorOverrideString: nil,
            groupIdentifier: nil,
            topLeft: Point(x: 10, y: 5),
            bottomRight: Point(x: 8, y: 20),
            textColorOverride: nil)
    }

    static var invertedData: Self {
        TextData(
            titleIdentifier: "someId",
            textAlignment: .center,
            maxFontSizeOverride: nil,
            fontOverride: nil,
            textColorOverrideString: nil,
            groupIdentifier: nil,
            topLeft: Point(x: 10, y: 20),
            bottomRight: Point(x: 15, y: 5),
            textColorOverride: nil)
    }

}
