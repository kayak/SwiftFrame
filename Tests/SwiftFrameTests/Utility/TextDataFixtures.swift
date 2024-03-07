import AppKit
import Foundation
@testable import SwiftFrameCore

extension TextData {

    static let goodData = TextData(
        titleIdentifier: "someID",
        textAlignment: TextAlignment(horizontal: .center, vertical: .top),
        maxFontSizeOverride: nil,
        fontOverride: nil,
        textColorOverrideString: nil,
        groupIdentifier: nil,
        topLeft: Point(x: 10, y: 5),
        bottomRight: Point(x: 15, y: 20),
        textColorOverride: nil
    )

    static let invalidData = TextData(
        titleIdentifier: "someID",
        textAlignment: TextAlignment(horizontal: .center, vertical: .top),
        maxFontSizeOverride: nil,
        fontOverride: nil,
        textColorOverrideString: nil,
        groupIdentifier: nil,
        topLeft: Point(x: 10, y: 5),
        bottomRight: Point(x: 8, y: 20),
        textColorOverride: nil
    )

    static let invertedData = TextData(
        titleIdentifier: "someID",
        textAlignment: TextAlignment(horizontal: .center, vertical: .top),
        maxFontSizeOverride: nil,
        fontOverride: nil,
        textColorOverrideString: nil,
        groupIdentifier: nil,
        topLeft: Point(x: 10, y: 20),
        bottomRight: Point(x: 15, y: 5),
        textColorOverride: nil
    )

}
