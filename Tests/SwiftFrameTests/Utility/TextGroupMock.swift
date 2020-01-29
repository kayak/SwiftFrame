import AppKit
import Foundation
import SwiftFrameCore

struct TextGroupMock {

    static var goodData: JSONDictionary {
        [
            "identifier": "someID",
            "maxFontSize": CGFloat(200.00)
        ]
    }

    static var badData: JSONDictionary {
        [
            "titleIdentifier": "someID",
            "maxFontSize": 200
        ]
    }

    static func makeGoodData() throws -> TextGroup {
        try TextGroup(from: goodData)
    }

}
