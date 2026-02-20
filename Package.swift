// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NerdLogger",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NerdLogger",
            targets: ["NerdLogger"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/lukepistrol/SwiftLintPlugin.git", exact: "0.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NerdLogger",
            plugins: [.plugin(name: "SwiftLint", package: "SwiftLintPlugin")]
        ),
        .testTarget(
            name: "NerdLoggerTests",
            dependencies: ["NerdLogger"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
