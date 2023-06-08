import CustomDump
import Foundation
@testable import SwiftOpenAPI
import XCTest

final class SwiftOpenAPITests: XCTestCase {

	func testDecoding() async throws {
		let file = try Mocks.petsSwagger.getData()
		let decoder = JSONDecoder()
		let _ = try decoder.decode(OpenAPI.Document.self, from: file)
	}

	func testSchemeEncoding() throws {
		var references: OpenAPI.ComponentDictionary<JSONSchema> = [:]
		try JSONSchema.encode(LoginBody.example, into: &references)
		prettyPrint(references)
		XCTAssertNoDifference(
			references,
			[
				"SomeEnum": .string(allowedValues: "first", "second"),
				"LoginBody": .object(
					properties: [
						"username": .string(required: true),
						"password": .string(required: true),
						"tags": .array(nullable: true, items: .string).optionalSchemaObject(),
						"id": .string(format: .other("uuid"), required: true),
						"url": .string(format: .other("uri"), nullable: true).optionalSchemaObject(),
						"enumValue": .reference(.component(named: "SomeEnum")).optionalSchemaObject(),
						"comments": .object(nullable: true, additionalProperties: .b(.string)).optionalSchemaObject(),
						"int": .integer(nullable: true).optionalSchemaObject(),
					]
				),
			]
		)
		XCTAssertNoDifference(
			Set(references["LoginBody"]?.objectContext?.requiredProperties ?? []),
			["username", "password", "id"]
		)
	}

	func testDescriptions() throws {
		var references: OpenAPI.ComponentDictionary<JSONSchema> = [:]
		try JSONSchema.decode(CardMeta.self, into: &references)
		guard let schema = references["CardMeta"] else {
			XCTFail()
			return
		}
		XCTAssertEqual(schema.description, .cardMeta)
		switch schema {
		case let .object(_, object):
			let props = object.properties
			XCTAssertEqual(props["cardNumber"]?.description, .cardNumber)
			XCTAssertEqual(props["expiryYear"]?.description, .expiryYear)
			XCTAssertEqual(props["expiryMonth"]?.description, .expiryMonth)
			XCTAssertEqual(props["cvv"]?.description, .cvv)
		default:
			XCTFail()
		}
	}

	func testKeyEncoding() throws {
		var references: OpenAPI.ComponentDictionary<JSONSchema> = [:]
		try JSONSchema.encode(LoginBody.example, keyEncodingStrategy: .convertToSnakeCase, into: &references)
		XCTAssertNoDifference(
			references,
			[
				"SomeEnum": .string(allowedValues: "first", "second"),
				"LoginBody": .object(
					properties: [
						"username": .string(required: true),
						"password": .string(required: true),
						"tags": .array(nullable: true, items: .string).optionalSchemaObject(),
						"id": .string(format: .other("uuid"), required: true),
						"url": .string(format: .other("uri"), nullable: true).optionalSchemaObject(),
						"enum_value": .reference(.component(named: "SomeEnum")).optionalSchemaObject(),
						"comments": .object(nullable: true, additionalProperties: .b(.string)).optionalSchemaObject(),
						"int": .integer(nullable: true).optionalSchemaObject(),
					]
				),
			]
		)
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
