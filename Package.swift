// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iBanner",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "iBanner", targets: ["iBanner"]),
    ],
    targets: [
        .target(
            name: "iBanner",
            path: "Sources/iBanner"
        ),
        .testTarget(
            name: "iBannerTests",
            dependencies: ["iBanner"],
            path: "Tests/iBannerTests"
        ),
    ]
)
