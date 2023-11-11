import CustomDump
import Foundation
@testable import SwiftOpenAPI
import XCTest

class ArrayDecodingTests: XCTestCase {
    
    func testDecodeArray() throws {
        var schemas: ComponentsMap<SchemaObject> = [:]
        _ = try ReferenceOr<SchemaObject>.decodeSchema(Tag.ListResponse.self, into: &schemas)
        XCTAssertNoDifference(
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
