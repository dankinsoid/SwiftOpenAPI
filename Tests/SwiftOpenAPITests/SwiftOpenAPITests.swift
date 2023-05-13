import Foundation
@testable import SwiftOpenAPI
import XCTest

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
                "SomeEnum": .enum(cases: ["first", "second"]),
                "LoginBody": .object(
                    properties: [
                        "username": .string,
                        "password": .string,
                        "tags": .array(of: .string),
                        "id": .uuid,
                        "url": .uri,
                        "enumValue": .ref(components: \.schemas, "SomeEnum"),
                        "comments": .dictionary(of: .string),
                        "int": .integer
                    ],
                    required: ["id", "username", "password"]
                )
            ]
        )
    }
    
    func testDescriptions() throws {
        var references: [String: ReferenceOr<SchemaObject>] = [:]
        try SchemaObject.decode(CardMeta.self, into: &references)
        guard let schema = references["CardMeta"]?.object else {
            XCTFail()
            return
        }
        XCTAssertEqual(schema.description, .cardMeta)
        switch schema.type {
        case let .object(.some(props), _, _, _):
            XCTAssertEqual(props["cardNumber"]?.object?.description, .cardNumber)
            XCTAssertEqual(props["expiryYear"]?.object?.description, .expiryYear)
            XCTAssertEqual(props["expiryMonth"]?.object?.description, .expiryMonth)
            XCTAssertEqual(props["cvv"]?.object?.description, .cvv)
        default:
            XCTFail()
        }
    }
}

func prettyPrint(_ value: some Encodable) {
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try print(
            String(
                data: encoder.encode(value),
                encoding: .utf8
            ) ?? ""
        )
    } catch {
        print(value)
    }
}

struct LoginBody: Codable {
    
    var username: String
    var password: String
    var tags: Set<String>?
    var comments: [String: String]?
    var enumValue: SomeEnum?
    var url: URL?
    var id: UUID
    var int: Int?
    
    static let example = LoginBody(
        username: "User",
        password: "12345678",
        tags: ["tag"],
        comments: ["Danil": "Comment"],
        enumValue: .first,
        id: UUID(),
        int: 12
    )
}

enum SomeEnum: String, Codable, CaseIterable {

	case first, second
}

struct CardMeta: Codable, OpenAPIDescriptable {
    
    let cardNumber: String
    let expiryMonth: Int
    let expiryYear: Int
    let cvv: String
    
    static var openAPIDescription: OpenAPIDescriptionType? {
        OpenAPIDescription<CodingKeys>(.cardMeta)
            .add(for: .cardNumber, .cardNumber)
            .add(for: .expiryYear, .expiryYear)
            .add(for: .expiryMonth, .expiryMonth)
            .add(for: .cvv, .cvv)
    }
}

private extension String {
    
    static let cardMeta = "Card meta information"
    static let cardNumber = "Card number"
    static let expiryYear = "Card expiry year"
    static let expiryMonth = "Card expiry month"
    static let cvv = "Card CVV"
}
