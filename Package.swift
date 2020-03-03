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
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager", .revision("swift-5.1.4-RELEASE")),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0")
    ],
    targets: [
        .target(name: "SwiftFrame", dependencies: ["SwiftFrameCore"]),
        .target(name: "SwiftFrameCore", dependencies: ["SPMUtility", "Yams"]),
        .testTarget(name: "SwiftFrameTests", dependencies: ["SwiftFrameCore"])
    ]
)
