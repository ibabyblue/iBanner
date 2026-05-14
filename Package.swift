// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IBanner",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "IBanner", targets: ["IBanner"]),
    ],
    targets: [
        .target(
            name: "IBanner",
            path: "Sources/IBanner"
        ),
        .testTarget(
            name: "IBannerTests",
            dependencies: ["IBanner"],
            path: "Tests/IBannerTests"
        ),
    ]
)
