import Foundation
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftOpenAPIMacros
@testable import SwiftOpenAPI

let testMacros: [String: Macro.Type] = [
    "OpenAPIDescriptionMacro": OpenAPIDescriptionMacro.self
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

                public static var openAPIDescription: OpenAPIDescriptionType? {
                    OpenAPIDescription<CodingKeys>(#"A person."#)
                        .add(for: .name, #"The person's name."#)
                }
            }

            extension Person: OpenAPIDescriptable {
            }
            """,
            macros: testMacros
        )
    }

    func test_created_extension() {
        XCTAssertEqual(
            Person.openAPIDescription?.asStringOpenAPIDescription,
            OpenAPIDescription<String>("A person.")
                .add(for: "name", "The person's name.")
        )
    }
}

@OpenAPIAutoDescriptable
/// A person.
struct Person: Codable {

    /// The person's name.
    let name: String
    
    /// Computed property
    var computedProperty: Int {
        0
    }
    
    /// Lazy
    lazy var someLazyVar = 0
    
    /// Static value
    static var someStatic = ""
}
