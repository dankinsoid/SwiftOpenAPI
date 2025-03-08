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
		var references: ComponentsMap<SchemaObject> = [:]
		try SchemaObject.encode(LoginBody.example, into: &references)
		XCTAssertEqual(
			references,
			[
				"SomeEnum": .enum(cases: ["first", "second"]),
				"LoginBody": .object(
					properties: [
						"username": .string,
						"password": .string,
						"tags": .array(of: .string, uniqueItems: true).with(\.nullable, true),
						"comments": .dictionary(of: .string).with(\.nullable, true),
						"enumValue": .ref(components: \.schemas, "SomeEnum"),
						"url": .uri.with(\.nullable, true),
						"id": .uuid,
						"int": .integer.with(\.nullable, true),
					],
					required: ["id", "username", "password"]
				),
			]
		)
	}

	func testDescriptions() throws {
		var references: ComponentsMap<SchemaObject> = [:]
		try SchemaObject.decode(CardMeta.self, into: &references)
		guard let schema = references["CardMeta"]?.object else {
			XCTFail()
			return
		}
		XCTAssertEqual(schema.description, .cardMeta)
		switch schema.context {
		case let .object(context):
			XCTAssertEqual(context.properties?["cardNumber"]?.object?.description, .cardNumber)
			XCTAssertEqual(context.properties?["expiryYear"]?.object?.description, .expiryYear)
			XCTAssertEqual(context.properties?["expiryMonth"]?.object?.description, .expiryMonth)
			XCTAssertEqual(context.properties?["cvv"]?.object?.description, .cvv)
		default:
			XCTFail()
		}
	}

	func testSpecificationExtensionsWrapper() throws {
		var withSpec = WithSpecExtensions(wrappedValue: SchemaObject.string)
		let key: SpecificationExtensions.Key = "x-some-value"
		let value: AnyValue = 1
		withSpec.projectedValue[key] = value
		let data = try JSONEncoder().encode(withSpec)
		let decoded = try JSONDecoder().decode(WithSpecExtensions<SchemaObject>.self, from: data)
		XCTAssertEqual(decoded.projectedValue[key], value)
	}

	func testSpecificationExtensionsWrapperWithDictionary0() throws {
		var withSpec = WithSpecExtensions(wrappedValue: CallbackObject())
		withSpec.wrappedValue["some"] = .value(.delete(OperationObject(description: "Delete")))
		let key: SpecificationExtensions.Key = "x-some-value"
		let value: AnyValue = 1
		withSpec.projectedValue[key] = value
		let data = try JSONEncoder().encode(withSpec)
		let decoded = try JSONDecoder().decode(WithSpecExtensions<CallbackObject>.self, from: data)
		XCTAssertEqual(decoded.projectedValue[key], value)
		XCTAssertEqual(decoded.wrappedValue.value.count, 1)
	}

	func testSpecificationExtensionsWrapperWithDictionary1() throws {
		var withSpec = WithSpecExtensions(wrappedValue: ContentObject())
		withSpec.wrappedValue["some"] = .string
		let key: SpecificationExtensions.Key = "x-some-value"
		let value: AnyValue = 1
		withSpec.projectedValue[key] = value
		let data = try JSONEncoder().encode(withSpec)
		let decoded = try JSONDecoder().decode(WithSpecExtensions<ContentObject>.self, from: data)
		XCTAssertEqual(decoded.projectedValue[key], value)
		XCTAssertEqual(decoded.wrappedValue.value.count, 1)
	}

	func testEnumDescriptions() throws {
		var references: ComponentsMap<SchemaObject> = [:]
		try SchemaObject.decode(SomeIntEnum.self, into: &references)
		guard let schema = references["SomeIntEnum"]?.object else {
			XCTFail()
			return
		}
		XCTAssertEqual(schema.description, "• 1 → first\n• 2 → second")

		try SchemaObject.decode(SomeDoubleEnum.self, into: &references)
		guard let doubleSchema = references["SomeDoubleEnum"]?.object else {
			XCTFail()
			return
		}
		XCTAssertEqual(doubleSchema.description, "• 1.1 → first\n• 2.2 → second")
	}

	func testSpecificationKeys() throws {
		let value = InfoObject(title: "Title", termsOfService: URL(string: "http://google.com"), version: "1.0.0")
		let specs = try SpecificationExtensions(from: value)
		XCTAssertEqual(specs["x-terms-of-service"], "http://google.com")
		XCTAssertEqual(specs["x-title"], "Title")
		XCTAssertEqual(specs["x-version"], "1.0.0")
	}

	func testSpecificationExtensions() throws {
		var info = InfoObject(title: "Title", termsOfService: URL(string: "http://google.com"), version: "1.0.0")
		let key: SpecificationExtensions.Key = "x-some-value"
		let value: AnyValue = 1
		info.specificationExtensions = [
			key: value,
		]
		let api = OpenAPIObject(info: info)
		let data = try JSONEncoder().encode(api)
		let decoded = try JSONDecoder().decode(OpenAPIObject.self, from: data).info
		XCTAssertEqual(decoded.specificationExtensions?[key], value)
	}

	func testKeyEncoding() throws {
		var references: ComponentsMap<SchemaObject> = [:]
		try SchemaObject.encode(LoginBody.example, keyEncodingStrategy: .convertToSnakeCase, into: &references)
		XCTAssertEqual(
			references,
			[
				"SomeEnum": .enum(cases: ["first", "second"]),
				"LoginBody": .object(
					properties: [
						"username": .string,
						"password": .string,
						"tags": .array(of: .string, uniqueItems: true).with(\.nullable, true),
						"comments": .dictionary(of: .string).with(\.nullable, true),
						"enum_value": .ref(components: \.schemas, "SomeEnum"),
						"url": .uri.with(\.nullable, true),
						"id": .uuid,
						"int": .integer.with(\.nullable, true),
					],
					required: ["id", "username", "password"]
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

enum SomeIntEnum: Int, Codable, CaseIterable {

	case first = 1, second = 2
}

enum SomeDoubleEnum: Double, Codable, CaseIterable {

	case first = 1.1
	case second = 2.2
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
