// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SharedHelper-iOS",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Networking",
            targets: ["Networking"]),
        .library(
            name: "Authentication",
            targets: ["Authentication"]),
        .library(
            name: "SecurityHandler",
            targets: ["SecurityHandler"]),
        .library(
            name: "Tracking",
            targets: ["Tracking"]),
        .library(name: "UIComponents",
                 targets: ["UIComponents"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/mixpanel/mixpanel-swift",
            from: "4.0.3"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Networking",
            dependencies: []),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]),
        .target(
            name: "Authentication",
            dependencies: ["SecurityHandler", "Networking",]),
        .target(
            name: "SecurityHandler",
            dependencies: [],
            resources: [.process("Resources")]),
        .target(
            name: "Tracking",
            dependencies: [
                .product(name: "Mixpanel", package: "mixpanel-swift"),
            ]),
        .target(
            name: "UIComponents",
            dependencies: [],
            resources: [
                .process("Resources/Font/AcademySans"),
                .process("Resources/Assets/Icons")
            ]
        ),
        .testTarget(
            name: "SecurityHandlerTests",
            dependencies: ["SecurityHandler"]),
        .testTarget(
            name: "AuthenticationTests",
            dependencies: ["Authentication"])
    ]
)
