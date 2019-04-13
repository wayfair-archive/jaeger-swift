// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Jaeger",
    platforms: [
       .macOS(.v10_12),
       .iOS(.v10),
       .tvOS(.v10)
    ],
    products: [
        .library(
            name: "Jaeger",
            targets: ["Jaeger"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Jaeger",
            dependencies: []),
        .testTarget(
            name: "JaegerTests",
            dependencies: ["Jaeger"])
    ]
)
