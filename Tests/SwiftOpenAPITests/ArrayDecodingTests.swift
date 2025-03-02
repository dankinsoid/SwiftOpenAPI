import Foundation
@testable import SwiftOpenAPI
import XCTest

class ArrayDecodingTests: XCTestCase {
    
    func testDecodeArray() throws {
        var schemas: ComponentsMap<SchemaObject> = [:]
        _ = try ReferenceOr<SchemaObject>.decodeSchema(Tag.ListResponse.self, into: &schemas)
        XCTAssertEqual(
            schemas,
            [
                "TagResponse": .object(
                    properties: [
                        "id": .integer,
                        "value": .string
                    ],
                    required: [
                        "id",
                        "value"
                    ]
                ),
                "TagListResponse": .object(
                    properties: [
                        "tags": .array(of: .ref(components: \.schemas, "TagResponse"))
                    ],
                    required: ["tags"]
                )
            ]
        )
    }
    
    func testEncodeRecursiveArray() throws {
        var schemas: ComponentsMap<SchemaObject> = [:]
        _ = try ReferenceOr<SchemaObject>.encodeSchema(ProductDependency.example, into: &schemas)
        XCTAssertEqual(schemas, ["ProductDependency": .value(ProductDependency.scheme)])
    }
    
    func testDecodeRecursiveArray() throws {
        var schemas: ComponentsMap<SchemaObject> = [:]
        _ = try ReferenceOr<SchemaObject>.encodeSchema(ProductDependency.example, into: &schemas)
        XCTAssertEqual(schemas, ["ProductDependency": .value(ProductDependency.scheme)])
    }

    func testDecodeEmbeddedRecursiveOptionalArray() throws {
        var schemas: ComponentsMap<SchemaObject> = [:]
        let _ = try ReferenceOr<SchemaObject>.encodeSchema(EmbeddedOptionalRecursiveTypeInArray.example, into: &schemas)
        XCTAssertEqual(
            schemas["EmbeddedOptionalRecursiveTypeInArray"],
            .value(EmbeddedOptionalRecursiveTypeInArray.scheme)
        )
        XCTAssertEqual(
            schemas["ProductDependency"],
            .value(ProductDependency.scheme)
        )
    }
    
    func testURL() throws {
        var schemas: ComponentsMap<SchemaObject> = [:]
        let _ = try ReferenceOr<SchemaObject>.decodeSchema(URL.self, into: &schemas)
        prettyPrint(schemas)
    }
}
    
enum Tag {
    
    struct Response: Codable {
        
        let id: Int
        let value: String
    }
    
    struct ListResponse: Codable {
        let tags: [Response]
    }
}

public struct EmbeddedOptionalRecursiveTypeInArray: Codable, Equatable {
    public var name: String
    public var dependencies: [ProductDependency]?

    public static let example = EmbeddedOptionalRecursiveTypeInArray(
        name: "DTOExample",
        dependencies: [ProductDependency.example]
    )

    static let scheme: SchemaObject = .object(
        properties: [
            "name": .string,
            "dependencies": .array(of: .ref(components: \.schemas, "ProductDependency"))
                .with(\.nullable, true)
        ],
        required: ["name"]
    )
}

public struct ProductDependency: Codable, Equatable {

    public var identity: String
    public var name: String
    public var url: String
    public var dependencies: [ProductDependency]
    
    public init(identity: String, name: String, url: String, dependencies: [ProductDependency]) {
        self.identity = identity
        self.name = name
        self.url = url
        self.dependencies = dependencies
    }
    
    public static let example = ProductDependency(
        identity: "0",
        name: "name",
        url: "http://vapor.com",
        dependencies: []
    )
    
    static let scheme: SchemaObject = .object(
        properties: [
            "identity": .string,
            "name": .string,
            "url": .string,
            "dependencies": .array(of: .ref(components: \.schemas, "ProductDependency"))
        ],
        required: ["identity", "name", "url", "dependencies"]
    )
}

public struct WebSocketBody: Codable {
    
    public var counter: Int
    public var content: URL?
    
    public init(_ content: URL?, counter: Int) {
        self.content = content
        self.counter = counter
    }
}
