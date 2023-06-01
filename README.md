# SwiftOpenAPI

[![CI Status](https://img.shields.io/travis/dankinsoid/SwiftOpenAPI.svg?style=flat)](https://travis-ci.org/dankinsoid/SwiftOpenAPI)
[![Version](https://img.shields.io/cocoapods/v/SwiftOpenAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOpenAPI)
[![License](https://img.shields.io/cocoapods/l/SwiftOpenAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOpenAPI)
[![Platform](https://img.shields.io/cocoapods/p/SwiftOpenAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOpenAPI)


## Description
SwiftOpenAPI is a Swift library which can generate output compatible with [OpenAPI](https://swagger.io/specification/) version 3.1.0. You can describe your API using `OpenAPIObject` type.\
The main accent in the library is on simplifying the syntax: the active use of literals (array, dictionary, string etc) and static methods greatly simplifies writing and reading `OpenAPI` docs in `Swift`.

## Short example
```swift
try OpenAPIObject(
    openapi: "3.0.1",
    info: InfoObject(
        title: "Example API",
        version: "0.1.0"
    ),
    servers: [
        "https://example-server.com",
        "https://example-server-test.com"
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
                    .ok: .ref(components: \.responses, "LoginResponse"),
                    .unauthorized: .ref(components: \.responses, "ErrorResponse")
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
            ],
            "LoginResponse": .value(.encode(LoginResponse.example))
        ],
        examples: [
            "LoginBody": [
                "username": "SomeUser",
                "password": "12345678"
            ],
            "LoginResponse": .value(
            	ExampleObject(value: .encode(LoginResponse.example))
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
## Pets store example
[PetsSwagger.swift](Tests/SwiftOpenAPITests/Mocks/PetsSwagger.swift) demonstrates syntaxis well

## Creating schemas and parameters for `Codable` types
There is a possibility to create `SchemeObject`, `[ParameterObject]`, `AnyValue` and `[String: HeaderObject]` instances from `Codable` types. It's possible to use `SchemeObject.decode/encode`, `[ParameterObject].decode/encode`, `[String: HeaderObject].decode/encode` and `AnyValue.encode` methods for it.
```swift
let loginBodySchemeFromType: SchemeObject = try .decode(LoginBody.self)
let loginBodySchemeFromInstance: SchemeObject = try .encode(LoginBody.example)
let loginBodyExample = try ExampleObject(value: .encode(LoginBody.example))
```
You can customize the encoding/decoding result by implementing `OpenAPIDescriptable` and `OpenAPIType` protocols.
1. `OpenAPIDescriptable` protocol allows you to provide a custom description for the type and its properties.
```swift
struct LoginBody: Codable, OpenAPIDescriptable {
    
    static var openAPIDescription: OpenAPIDescriptionType? {
        OpenAPIDescription<CodingKeys>("Login body")
            .add(for: .username, "Username")
            .add(for: .password, "Password")
    }
}
```
2. `OpenAPIType` protocol allows you to provide a custom schema for the type.
```swift
struct Color: Codable, OpenAPIType {
    
    static var openAPISchema: SchemaObject {
        .string(format: "hex", description: "Color in hex format")
    }
}
```

## Specification extensions
While the OpenAPI Specification tries to accommodate most use cases, [additional data](https://swagger.io/specification/#specification-extensions) can be added to extend the specification at certain points.\
```swift
var api = OpenAPIObject(...)
api.specificationExtensions = ["x-some-extension": "some value"]
// or
api.specificationExtensions = try? SpecificationExtensions(from: someEncodable)
```
It was a bit tricky challenge to implement additional dynamic properties for any codable struct. The solution is to use `SpecificationExtendable` protocol in combination with `WithSpecExtensions` property wrapper.
There is two ways to decode/encode `SpecificationExtendable` types with additional properties:
1. Use `SpecificationExtendable.json`, `SpecificationExtendable.Type.from(json:)` methods.
```swift
let schema = try SchemaObject.from(json: jsonData)
let jsonData = try schema.json()
```
2. If you cannot use custom decoding methods, you can use `WithSpecExtensions` wrapper.
```swift
let api = try WithSpecExtensions(wrappedValue: OpenAPIObject(...))
let jsonData = try JSONEncoder().encode(api)
```

## TODO
- `URI` type instead of `String`
- `refactor` method on `OpenAPIObject` (?)
- Extend `RuntimeExpression` type
- `DataEncodingFormat`

## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/SwiftOpenAPI.git", from: "2.16.2")
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

## Related projects
- [VaporToOpenAPI](https://github.com/dankinsoid/VaporToOpenAPI.git)

## Author

dankinsoid, voidilov@gmail.com

## License

SwiftOpenAPI is available under the MIT license. See the LICENSE file for more info.
