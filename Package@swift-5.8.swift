// swift-tools-version:5.8

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
            path: "Sources",
            swiftSettings: .upcomingFeatures
        ),
        .testTarget(
            name: "AllocatedLockTests",
            dependencies: ["AllocatedLock"],
            path: "Tests",
            swiftSettings: .upcomingFeatures
        )
    ]
)

extension Array where Element == SwiftSetting {

    static var upcomingFeatures: [SwiftSetting] {
        [
            .enableExperimentalFeature("StrictConcurrency")
        ]
    }
}
