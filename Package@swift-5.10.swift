// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Mutex",
    platforms: [
 	   .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Mutex",
            targets: ["Mutex"]
        )
    ],
    targets: [
        .target(
            name: "Mutex",
            path: "Sources",
            swiftSettings: .upcomingFeatures
        ),
        .testTarget(
            name: "MutexTests",
            dependencies: ["Mutex"],
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
