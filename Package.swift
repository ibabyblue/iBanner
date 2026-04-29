// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "iBanner",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "iBanner", targets: ["iBanner"]),
        .library(name: "iBannerDemo", targets: ["iBannerDemo"]),
    ],
    targets: [
        .target(
            name: "iBanner",
            path: "Sources/iBanner"
        ),
        .target(
            name: "iBannerDemo",
            dependencies: ["iBanner"],
            path: "demo/Sources"
        ),
        .testTarget(
            name: "iBannerTests",
            dependencies: ["iBanner"],
            path: "Tests/iBannerTests"
        ),
    ]
)
