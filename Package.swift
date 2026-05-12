// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MiniAppX",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "MiniAppX",
            targets: ["MiniAppX"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/miniapp-io/miniapp-lib-uikit.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MiniAppX",
            dependencies: [
                .product(name: "MiniAppUIKit", package: "miniapp-lib-uikit")
            ],
            path: ".",
            sources: ["OpenPlatform"],
            resources: [
                .process("MiniAppXResources.bundle")
            ]
        )
    ]
)
