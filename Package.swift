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
        .executable(
            name: "SwiftOpenAPIClient",
            targets: ["SwiftOpenAPIClient"]
        ),
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "0.10.3"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b")
	],
	targets: [
        .macro(
            name: "SwiftOpenAPIMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
		.target(name: "SwiftOpenAPI", dependencies: ["SwiftOpenAPIMacros"]),
        .executableTarget(name: "SwiftOpenAPIClient", dependencies: ["SwiftOpenAPI"]),
		.testTarget(
			name: "SwiftOpenAPITests",
			dependencies: [
				"SwiftOpenAPI",
				.product(name: "CustomDump", package: "swift-custom-dump")
			],
			exclude: ["Mocks/"]
		),
	]
)
