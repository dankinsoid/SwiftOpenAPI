import Foundation
import OpenAPIKit

struct HeadersEncoder {

	var dateFormat: DateEncodingFormat
	var keyEncodingStrategy: KeyEncodingStrategy

	@discardableResult
	func encode(
		_ value: Encodable,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Header.Map {
		try parse(
			value: TypeRevision().describeType(of: value),
			type: type(of: value),
			into: &schemas
		)
	}

	@discardableResult
	func decode(
		_ type: Decodable.Type,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Header.Map {
		try parse(
			value: TypeRevision().describe(type: type),
			type: type,
			into: &schemas
		)
	}

	private func parse(
		value: TypeInfo,
		type: Any.Type,
		into schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Header.Map {
		switch type {
		case is URL.Type:
			throw InvalidType()

		default:
			switch value.container {
			case .single, .unkeyed, .recursive:
				throw InvalidType()

			case let .keyed(keyedInfo):
				return try keyedInfo.fields
					.mapKeys(keyEncodingStrategy.encode)
					.mapValues {
						try .b(
							OpenAPI.Header(
								schema: .header(
									SchemeEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
										.parse(value: $0, type: $0.type, into: &schemas),
									example: $0.container.anyValue
								)
							)
						)
					}
					.with(description: (type as? OpenAPIDescriptable.Type)?.openAPIDescription)
			}
		}
	}
}

public extension OpenAPI.Header.Map {
	
	static func encode(
		_ value: Encodable,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Header.Map {
		try HeadersEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
			.encode(value, schemas: &schemas)
	}
	
	static func decode(
		_ type: Decodable.Type,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Header.Map {
		try HeadersEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
			.decode(type, schemas: &schemas)
	}
}
