// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Feature",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ChannelFeature", targets: ["ChannelFeature"]),
        .library(name: "ChannelTreeFeature", targets: ["ChannelTreeFeature"]),
        .library(name: "MarkdownFeature", targets: ["MarkdownFeature"]),
        .library(name: "SessionFeature", targets: ["SessionFeature"]),
        .library(name: "TraqAPI", targets: ["TraqAPI"]),
        .library(name: "Views", targets: ["Views"])
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.1"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.6.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.2"),
    ],
    targets: [
        .target(
            name: "ChannelFeature",
            dependencies: [
                "MarkdownFeature",
                "TraqAPI",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "ChannelTreeFeature",
            dependencies: [
                "ChannelFeature",
                "TraqAPI",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "MarkdownFeature",
            dependencies: [
                "TraqAPI",
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
            ]
        ),
        .target(
            name: "SessionFeature",
            dependencies: [
                "TraqAPI",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "TraqAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
            ]
        ),
        .target(
            name: "Views",
            dependencies: [
                "ChannelTreeFeature",
                "SessionFeature",
            ]
        ),
    ]
)
