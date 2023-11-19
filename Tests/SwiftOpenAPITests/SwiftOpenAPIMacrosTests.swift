import Foundation
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import SwiftOpenAPIMacros
@testable import SwiftOpenAPI

let testMacros: [String: Macro.Type] = [
    "OpenAPIAutoDescriptable": OpenAPIDescriptionMacro.self
]

final class OpenAPIDescriptionMacroTests: XCTestCase {

    func test_should_create_extension() {
        assertMacroExpansion(
            """
            /// A person.
            @OpenAPIAutoDescriptable
            struct Person: Codable {
            
                /// The person's name.
                let name: String
            }
            """,
            expandedSource: """
            /// A person.
            struct Person: Codable {
            
                /// The person's name.
                let name: String
            }

            extension Person: OpenAPIDescriptable {
            
                public static var openAPIDescription: OpenAPIDescriptionType? {
                    OpenAPIDescription<String>(#"A person."#)
                        .add(for: "name", #"The person's name."#)
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func test_created_extension() {
        XCTAssertEqual(
            Person.openAPIDescription as? OpenAPIDescription<String>,
            OpenAPIDescription<String>("A person.")
                .add(for: "name", "The person's name.")
        )
    }
}

@OpenAPIAutoDescriptable
/// A person.
struct Person {

    /// The person's name.
    let name: String
}
