# SwiftOpenAPI

[![CI Status](https://img.shields.io/travis/dankinsoid/SwiftOpenAPI.svg?style=flat)](https://travis-ci.org/dankinsoid/SwiftOpenAPI)
[![Version](https://img.shields.io/cocoapods/v/SwiftOpenAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOpenAPI)
[![License](https://img.shields.io/cocoapods/l/SwiftOpenAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOpenAPI)
[![Platform](https://img.shields.io/cocoapods/p/SwiftOpenAPI.svg?style=flat)](https://cocoapods.org/pods/SwiftOpenAPI)


## Description
SwiftOpenAPI is a Swift library which can generate output compatible with [OpenAPI](https://swagger.io/specification/) version 3.1.0. You can describe your API using `OpenAPIObject` type.

## Example

```swift

```
## Usage

 
## Installation

1. [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.
```swift
// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "SomeProject",
  dependencies: [
    .package(url: "https://github.com/dankinsoid/SwiftOpenAPI.git", from: "0.0.1")
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
