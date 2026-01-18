// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "BaresipExample",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftBaresip",
            targets: ["SwiftBaresip"]
        )
    ],
    targets: [
        .target(
            name: "SwiftBaresip",
            dependencies: [],
            path: "bridge/SwiftBaresip",
            exclude: ["Baresip-Bridging-Header.h"],
            publicHeadersPath: "."
        ),
        .testTarget(
            name: "BaresipTests",
            dependencies: ["SwiftBaresip"],
            path: "tests"
        )
    ]
)
