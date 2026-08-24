// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "tws-api-swift",
	platforms: [
		.macOS(.v26)
	],
    products: [
        .library(
            name: "TWSAPI",
            targets: ["TWSAPI"]
        ),
		.library(
			name: "TWSModels",
			targets: ["TWSModels"]
		)
    ],
	dependencies: [
		.package(url: "https://github.com/apple/swift-protobuf.git", from: "1.38.0"),
		.package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0")

	],
    targets: [
		.target(
			name: "TWSModels",
			dependencies: [
				.product(name: "SwiftProtobuf", package: "swift-protobuf"),
			]
		),
        .target(
            name: "TWSAPI",
			dependencies: [
				"TWSModels",
				.product(name: "NIOCore", package: "swift-nio"),
				.product(name: "NIOPosix", package: "swift-nio"),
				.product(name: "NIOHTTP1", package: "swift-nio")
			]
        ),
        .testTarget(
            name: "TWSAPITests",
            dependencies: ["TWSModels"]
        ),
		.testTarget(
			name: "TWSModelsTests"
		),
    ],
    swiftLanguageModes: [.v6]
)
