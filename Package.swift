// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Patchwork",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "Patchwork", targets: ["Patchwork"]),
    ],
    dependencies: [
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.9.0"),
    ],
    targets: [
        .target(name: "Patchwork", dependencies: []),
        .testTarget(
            name: "PatchworkTest",
            dependencies: ["Patchwork","SnapshotTesting"],
            exclude: ["__Snapshots__", "IndividualFeatures/__Snapshots__"]),
    ]
)
