// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "SwiftOpenAPI",
	platforms: [
		.macOS(.v10_15),
		.iOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
	],
	products: [
		.library(name: "SwiftOpenAPI", targets: ["SwiftOpenAPI"]),
	],
	dependencies: [
        .package(url: "https://github.com/mattpolzin/OpenAPIKit.git", from: "3.0.0-beta.2"),
		.package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.0.0"),
	],
	targets: [
		.target(name: "SwiftOpenAPI", dependencies: ["OpenAPIKit"]),
		.testTarget(
			name: "SwiftOpenAPITests",
			dependencies: [
				"SwiftOpenAPI",
				.product(name: "CustomDump", package: "swift-custom-dump"),
			],
			exclude: ["Mocks/"]
		),
	]
)
