// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "AllocatedLock",
    platforms: [
 	   .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "AllocatedLock",
            targets: ["AllocatedLock"]
        )
    ],
    targets: [
        .target(
            name: "AllocatedLock",
            path: "Sources"
        ),
        .testTarget(
            name: "AllocatedLockTests",
            dependencies: ["AllocatedLock"],
            path: "Tests"
        )
    ]
)
