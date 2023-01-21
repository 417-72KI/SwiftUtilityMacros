// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftMacros",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftMacros",
            targets: ["SwiftMacros"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax",
                 branch: "swift-DEVELOPMENT-SNAPSHOT-2023-01-20-a"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
                .product(name: "_SwiftSyntaxMacros", package: "swift-syntax"),
            ]),
        .testTarget(
            name: "SwiftMacrosTests",
            dependencies: [
                "SwiftMacros",
                 // .product(name: "_SwiftSyntaxTestSupport", package: "swift-syntax"),
            ]),
    ]
)
