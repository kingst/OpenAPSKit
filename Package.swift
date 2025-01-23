// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "OpenAPSKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "OpenAPSKit",
            targets: ["OpenAPSKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OpenAPSKit",
            dependencies: []
        ),
        .testTarget(
            name: "OpenAPSKitTests",
            dependencies: ["OpenAPSKit"]
        ),
    ]
)
