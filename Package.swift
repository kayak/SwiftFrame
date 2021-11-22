// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftFrame",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "swiftframe", targets: ["SwiftFrame"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "SwiftFrame",
            dependencies: [
                "SwiftFrameCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(name: "SwiftFrameCore", dependencies: ["Yams"]),
        .testTarget(name: "SwiftFrameTests", dependencies: ["SwiftFrameCore"])
    ]
)
