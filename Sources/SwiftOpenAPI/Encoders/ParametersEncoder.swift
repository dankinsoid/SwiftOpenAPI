import Foundation
import OpenAPIKit

struct ParametersEncoder {

	var location: OpenAPI.Parameter.Context.Location
	var dateFormat: DateEncodingFormat
	var keyEncodingStrategy: KeyEncodingStrategy

	@discardableResult
	func encode(
		_ value: Encodable,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Parameter.Array {
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
	) throws -> OpenAPI.Parameter.Array {
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
	) throws -> OpenAPI.Parameter.Array {
		switch type {
		case is URL.Type:
			throw InvalidType()

		default:
			switch value.container {
			case .single, .unkeyed, .recursive:
				throw InvalidType()

			case let .keyed(keyedInfo):
				return try keyedInfo.fields.map {
					let context: OpenAPI.Parameter.Context
					switch location {
					case .cookie:
						context = .cookie(required: !$0.value.isOptional)
					case .header:
						context = .header(required: !$0.value.isOptional)
					case .query:
						context = .query(required: !$0.value.isOptional)
					case .path:
						context = .path
					}
					return try OpenAPI.Parameter(
						name: keyEncodingStrategy.encode($0.key),
						context: context,
						schema: OpenAPI.Parameter.SchemaContext(
							SchemeEncoder(
								dateFormat: dateFormat,
								keyEncodingStrategy: keyEncodingStrategy
							).parse(value: $0.value, type: $0.value.type, into: &schemas),
							style: .default(for: context),
							example: $0.value.container.anyValue
						)
					)
				}
				.sorted { $0.name < $1.name }
				.map { .b($0) }
				.with(description: (type as? OpenAPIDescriptable.Type)?.openAPIDescription)
			}
		}
	}
}

struct InvalidType: Error {}

public extension OpenAPI.Parameter.Array {

	static func encode(
		_ value: Encodable,
		in location: OpenAPI.Parameter.Context.Location,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Parameter.Array {
		try ParametersEncoder(location: location, dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
			.encode(value, schemas: &schemas)
	}

	static func decode(
		_ type: Decodable.Type,
		in location: OpenAPI.Parameter.Context.Location,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Parameter.Array {
		try ParametersEncoder(location: location, dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
			.decode(type, schemas: &schemas)
	}
}
