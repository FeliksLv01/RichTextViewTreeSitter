// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TreeSitterBinaryConsumer",
    platforms: [.iOS(.v15)],
    products: [.library(name: "TreeSitterBinaryConsumer", targets: ["TreeSitterBinaryConsumer"])],
    targets: [
        .binaryTarget(name: "TreeSitter", path: "TreeSitter.xcframework"),
        .binaryTarget(name: "SwiftTreeSitter", path: "SwiftTreeSitter.xcframework"),
        .binaryTarget(name: "TreeSitterSwift", path: "TreeSitterSwift.xcframework"),
        .target(
            name: "TreeSitterBinaryConsumer",
            dependencies: ["TreeSitter", "SwiftTreeSitter", "TreeSitterSwift"]
        )
    ]
)
