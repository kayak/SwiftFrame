// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFrame",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(name: "swiftframe", targets: ["SwiftFrame"])
    ],
    targets: [
        .target(name: "SwiftFrame", dependencies: ["SwiftFrameCore"]),
        .target(name: "SwiftFrameCore"),
        .testTarget(
            name: "SwiftFrameTests",
            dependencies: ["SwiftFrameCore"]),
    ]
)
