import AppKit
import Foundation
import SwiftFrameCore

struct TextDataContainer {

    static let goodData: [String : Any] = [
        "titleIdentifier": "someID",
        "textAlignment": NSTextAlignment.center,
        "topLeft": Point(x: 10, y: 20),
        "bottomRight": Point(x: 15, y: 5)
    ]

    static let badData: [String : Any] = [
        "titleIdentifier": "someID",
        "textAlignment": 1,
        "topLeft": Point(x: 15, y: 5),
        "bottomRight": Point(x: 15, y: 20)
    ]

    static let invalidData: [String : Any] = [
        "titleIdentifier": "someID",
        "textAlignment": NSTextAlignment.center,
        "topLeft": Point(x: 10, y: 5),
        "bottomRight": Point(x: 8, y: 20)
    ]

}

extension TextData {
    static var mockData: TextData {
        return try! TextData(from: TextDataContainer.goodData)
    }
}
