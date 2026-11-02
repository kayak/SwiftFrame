import AppKit
import Foundation
import Testing

@testable import SwiftFrameCore

// `AttributedStringCache.process` must run on the main thread.
@MainActor
struct AttributedStringCacheTests {

    @Test("Cached strings are immutable, so threads can share them")
    func cachedStringIsImmutable() throws {
        let locale = UUID().uuidString
        let textData = TextData(
            titleIdentifier: "someID",
            textAlignment: TextAlignment(horizontal: .center, vertical: .top),
            maxFontSizeOverride: nil,
            fontOverride: nil,
            textColorOverrideString: nil,
            groupIdentifier: "someGroup",
            topLeft: Point(x: 10, y: 5),
            bottomRight: Point(x: 15, y: 20)
        )

        try AttributedStringCache.shared.process(
            [("Some interesting title", textData)],
            locale: locale,
            deviceIdentifier: "someDevice",
            maxFontSizeByGroup: ["someGroup": 20],
            font: .systemFont(ofSize: 20),
            color: .white,
            maxFontSize: 20
        )
        let cachedString = try AttributedStringCache.shared.attributedString(
            forTitleIdentifier: "someID",
            locale: locale,
            deviceIdentifier: "someDevice"
        )

        #expect(cachedString.string == "Some interesting title")
        #expect(!(cachedString is NSMutableAttributedString))
    }

}
