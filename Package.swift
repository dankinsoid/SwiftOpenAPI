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
	],
	targets: [
		.target(name: "SwiftOpenAPI", dependencies: []),
		.testTarget(
			name: "SwiftOpenAPITests",
			dependencies: [
				"SwiftOpenAPI"
			],
			exclude: ["Mocks/"]
		),
	]
)
