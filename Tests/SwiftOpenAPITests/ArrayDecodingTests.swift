import CustomDump
import Foundation
@testable import SwiftOpenAPI
import XCTest

class ArrayDecodingTests: XCTestCase {
    
    func testDecodeArray() throws {
        var schemas: ComponentsMap<SchemaObject> = [:]
        _ = try ReferenceOr<SchemaObject>.decodeSchema(Tag.ListResponse.self, into: &schemas)
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
