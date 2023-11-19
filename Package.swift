// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

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
		.package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "0.10.3"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.2")
	],
	targets: [
		.target(name: "SwiftOpenAPI", dependencies: ["SwiftOpenAPIMacros"]),
        .macro(
            name: "SwiftOpenAPIMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
		.testTarget(
			name: "SwiftOpenAPITests",
			dependencies: [
				"SwiftOpenAPI",
                "SwiftOpenAPIMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
				.product(name: "CustomDump", package: "swift-custom-dump"),
			],
			exclude: ["Mocks/"]
		),
	]
)
