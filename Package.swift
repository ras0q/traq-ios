// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Feature",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "ChannelFeature", targets: ["ChannelFeature"]),
        .library(name: "ChannelRepository", targets: ["ChannelRepository"]),
        .library(name: "ChannelTreeFeature", targets: ["ChannelTreeFeature"]),
        .library(name: "MarkdownFeature", targets: ["MarkdownFeature"]),
        .library(name: "MessageRepository", targets: ["MessageRepository"]),
        .library(name: "Model", targets: ["Model"]),
        .library(name: "SessionFeature", targets: ["SessionFeature"]),
        .library(name: "SessionRepository", targets: ["SessionRepository"]),
        .library(name: "TraqAPI", targets: ["TraqAPI"]),
        .library(name: "Views", targets: ["Views"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ras0q/actuate", branch: "main"),
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.1"),
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.12.1"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.11.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "Model",
            dependencies: ["TraqAPI"]
        ),
        .target(
            name: "SessionRepository",
            dependencies: ["Model", "TraqAPI"]
        ),
        .target(
            name: "ChannelRepository",
            dependencies: ["Model", "TraqAPI"]
        ),
        .target(
            name: "MessageRepository",
            dependencies: ["Model", "TraqAPI"]
        ),
        .target(
            name: "ChannelFeature",
            dependencies: [
                "MarkdownFeature",
                "MessageRepository",
                "Model",
                "TraqAPI",
                .product(name: "Actuate", package: "actuate"),
            ]
        ),
        .target(
            name: "ChannelTreeFeature",
            dependencies: [
                "ChannelFeature",
                "ChannelRepository",
                "Model",
                "TraqAPI",
                .product(name: "Actuate", package: "actuate"),
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
                "Model",
                "SessionRepository",
                "TraqAPI",
                .product(name: "Actuate", package: "actuate"),
            ]
        ),
        .target(
            name: "TraqAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        ),
        .target(
            name: "Views",
            dependencies: [
                "ChannelTreeFeature",
                "ChannelRepository",
                "MessageRepository",
                "Model",
                "SessionFeature",
                "SessionRepository",
            ]
        ),
    ]
)
