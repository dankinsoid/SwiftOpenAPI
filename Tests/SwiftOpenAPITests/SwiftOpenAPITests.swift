import Foundation
import XCTest
@testable import SwiftOpenAPI

final class SwiftOpenAPITests: XCTestCase {
    
    func testDecoding() async throws {
        let file = try Mocks.petsSwagger.getData()
        let decoder = JSONDecoder()
        let _ = try decoder.decode(OpenAPIObject.self, from: file)
    }
    
    func testSchemeEncoding() throws {
        var references: [String: ReferenceOr<SchemaObject>] = [:]
        try SchemaObject.encode(LoginBody.example, into: &references)
        XCTAssertEqual(
            references,
            [
                "SomeEnum": .value(
                    .enum(.string, allCases: ["first", "second"])
                ),
                "LoginBody": .value(
                    .object(
                        [
                            "username": .value(.primitive(.string)),
                            "password": .value(.primitive(.string)),
                            "tags": .value(.array(.value(.primitive(.string)))),
                            "id": .value(.primitive(.string, format: "uuid")),
                            "enumValue": .ref(components: \.schemas, "SomeEnum"),
                            "comments": .value(
                                .object(nil, required: nil, additionalProperties: .value(.primitive(.string)))
                            )
                        ],
                        required: ["id", "username", "password"]
                    )
                )
            ]
        )
    }
}

func prettyPrint(_ value: some Encodable) throws {
    try print(
        String(
            data: JSONSerialization.data(
                withJSONObject: JSONSerialization.jsonObject(
                    with: JSONEncoder().encode(value)
                ),
                options: .prettyPrinted
            ),
            encoding: .utf8
        ) ?? ""
    )
}


struct LoginBody: Codable {
    
    var username: String
    var password: String
    var tags: Set<String>?
    var comments: [String: String]?
    var enumValue: SomeEnum?
    var id: UUID
    
    static let example = LoginBody(
        username: "User",
        password: "12345678",
        tags: ["tag"],
        comments: ["Danil": "Comment"],
        enumValue: .first,
        id: UUID()
    )
}

enum SomeEnum: String, Codable, CaseIterable {
    
    case first, second
}
