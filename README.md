# SwiftOpenAPI

[![CI Status](https://img.shields.io/travis/dankinsoid/SwiftOpenAPI.svg?style=flat)](https://travis-ci.org/dankinsoid/SwiftOpenAPI)
[![Version](https://img.shields.io/cocoapods/v/SwiftOpenAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOpenAPI)
[![License](https://img.shields.io/cocoapods/l/SwiftOpenAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOpenAPI)
[![Platform](https://img.shields.io/cocoapods/p/SwiftOpenAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOpenAPI)


## Description
SwiftOpenAPI is a Swift library which can generate output compatible with [OpenAPI](https://swagger.io/specification/) version 3.1.0. You can describe your API using `OpenAPIObject` type.

## Example
```swift
OpenAPIObject(
    openapi: "3.0.1",
    info: InfoObject(
        title: "Example API",
        version: "0.1.0"
    ),
    servers: [
        ServerObject(url: "https://example-server.com"),
        ServerObject(url: "https://example-server-test.com")
    ],
    paths: [
        "services": .get(
            summary: "Get services",
            OperationObject(description: "Get services")
        ),
        "login": .post(
            OperationObject(
                description: "login",
                requestBody: .ref(components: \.requestBodies, "LoginRequest"),
                responses: [
                    .default: .ref(components: \.responses, "LoginResponse"),
                    401: .ref(components: \.responses, "ErrorResponse")
                ]
            )
        ),
        "/services/{serviceID}": [
            .get: OperationObject(description: "Get service"),
            .delete: OperationObject(description: "Delete service")
        ],
        "/services": .ref(components: \.pathItems, "T")
    ],
    components: ComponentsObject(
        schemas: [
            "LoginBody": [
                "username": .string,
                "password": .string
            ]
        ],
        examples: [
            "LoginBody": .value(
                ExampleObject(
                    value: [
                        "username": "SomeUser",
                        "password": "12345678"
                    ]
                )
            )
        ],
        requestBodies: [
            "LoginRequest": .value(
                RequestBodyObject(
                    content: [
                        .application(.json): MediaTypeObject(
                            schema: .ref(components: \.schemas, "LoginBody")
                        )
                    ],
                    required: nil
                )
            )
        ]
    )
)

```
 
## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/SwiftOpenAPI.git", from: "1.23.0")
  ],
  targets: [
    .target(name: "SomeProject", dependencies: ["SwiftOpenAPI"])
  ]
)
```
```ruby
$ swift build
```

2.  [CocoaPods](https://cocoapods.org)

Add the following line to your Podfile:
```ruby
pod 'SwiftOpenAPI'
```
and run `pod update` from the podfile directory first.

## Author

dankinsoid, voidilov@gmail.com

## License

SwiftOpenAPI is available under the MIT license. See the LICENSE file for more info.
