// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "ChineseStudyApp",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "ChineseStudyApp", type: .dynamic, targets: ["ChineseStudyApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/skiptools/skip.git", from: "1.9.7"),
        .package(url: "https://github.com/skiptools/skip-ui.git", from: "1.0.0"),
        .package(url: "https://github.com/skiptools/skip-sql.git", from: "0.16.0")
    ],
    targets: [
        .target(
            name: "ChineseStudyApp",
            dependencies: [
                .product(name: "SkipUI", package: "skip-ui"),
                .product(name: "SkipSQL", package: "skip-sql")
            ],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
        .testTarget(
            name: "ChineseStudyAppTests",
            dependencies: [
                "ChineseStudyApp"
            ],
            resources: [.process("Resources")]
        ),
    ]
)
