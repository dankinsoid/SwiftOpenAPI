import Foundation
import OpenAPIKit

struct SchemeEncoder {

	var extractReferences = true
	var dateFormat: DateEncodingFormat
	var keyEncodingStrategy: KeyEncodingStrategy

	@discardableResult
	func encode(
		_ value: Encodable,
		into schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> JSONSchema {
		let type = Swift.type(of: value)
		return try parse(
			value: TypeRevision().describeType(of: value),
			type: type,
			into: &schemas
		)
	}

	@discardableResult
	func decode(
		_ type: Decodable.Type,
		into schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> JSONSchema {
		try parse(
			value: TypeRevision().describe(type: type),
			type: type,
			into: &schemas
		)
	}

	func parse(
		value: @autoclosure () throws -> TypeInfo,
		type: Any.Type,
		into schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> JSONSchema {
		let name = String.typeName(type)
		var result: JSONSchema
		let typeInfo = try value()

		switch type {
		case is Date.Type:
			result = dateFormat.schema

		case let openAPI as OpenAPIType.Type:
			result = openAPI.openAPISchema

		default:
			switch typeInfo.container {
			case let .single(codableValues):
				let schema = try parse(value: codableValues)
				if let iterable = type as? any CaseIterable.Type {
					let allCases = iterable.allCases as any Collection
					result = schema.with(allowedValues: allCases.map { AnyCodable("\($0)") })
				} else {
					result = schema
				}

			case let .keyed(keyedInfo):
				switch keyedInfo.isFixed {
				case true:
					result = try JSONSchema.object(
						properties: Dictionary(
							keyedInfo.fields.map {
								try (
									keyEncodingStrategy.encode($0.key),
									parse(value: $0.value, type: $0.value.type, into: &schemas)
								)
							}
						) { _, s in s }
					)

				case false:
					result = try JSONSchema.object(
						additionalProperties: keyedInfo.fields.first.map {
							try .b(parse(value: $0.value, type: $0.value.type, into: &schemas))
						} ?? .a(true)
					)
				}

			case let .unkeyed(itemInfo):
				result = try JSONSchema.array(
					items: parse(value: itemInfo, type: itemInfo.type, into: &schemas)
				)

			case .recursive:
				result = .reference(.component(named: name.rawValue))
			}
		}

		if let descriptable = type as? OpenAPIDescriptable.Type {
			result = result.with(description: descriptable.openAPIDescription)
		}

		if extractReferences, result.isReferenceable {
			schemas[name] = result
			let ref: JSONSchema = .reference(.component(named: name.rawValue))
			return typeInfo.isOptional ? ref.optionalSchemaObject() : ref.requiredSchemaObject()
		} else {
			if typeInfo.isOptional {
				result = result.nullableSchemaObject().optionalSchemaObject()
			} else {
				result = result.requiredSchemaObject()
			}
			return result
		}
	}

	private func parse(
		value: CodableValues
	) throws -> JSONSchema {
		switch value {
		case .int:
			return Int.openAPISchema
		case .int8:
			return Int8.openAPISchema
		case .int16:
			return Int16.openAPISchema
		case .int32:
			return Int32.openAPISchema
		case .int64:
			return Int64.openAPISchema
		case .uint:
			return UInt.openAPISchema
		case .uint8:
			return UInt8.openAPISchema
		case .uint16:
			return UInt16.openAPISchema
		case .uint32:
			return UInt32.openAPISchema
		case .uint64:
			return UInt64.openAPISchema
		case .double:
			return Double.openAPISchema
		case .float:
			return Float.openAPISchema
		case .bool:
			return Bool.openAPISchema
		case .string:
			return String.openAPISchema
		case .null:
			return .string(nullable: true)
		}
	}
}

private extension JSONSchema {

	var isReferenceable: Bool {
		switch self {
		case let .boolean(core as JSONSchemaContext),
		     .number(let core as JSONSchemaContext, _),
		     .integer(let core as JSONSchemaContext, _),
		     .string(let core as JSONSchemaContext, _):
			return core.allowedValues?.isEmpty == false
		case .array, .fragment, .reference:
			return false
		case let .object(_, objectContext):
			return !objectContext.properties.isEmpty
		case .all, .one, .any, .not:
			return true
		}
	}
}

public extension JSONSchema {

	@discardableResult
	static func encode(
		_ value: Encodable,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		into schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> JSONSchema {
		let encoder = SchemeEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		return try encoder.encode(value, into: &schemas)
	}

	@discardableResult
	static func decode(
		_ type: Decodable.Type,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		into schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> JSONSchema {
		let encoder = SchemeEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		return try encoder.decode(type, into: &schemas)
	}
}

public extension OpenAPI.Content {

	static func encode(
		_ value: Encodable,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Content {
		try OpenAPI.Content(
			schema: .encode(value, into: &schemas),
			example: .encode(value)
		)
	}

	static func encode(
		_ value: Encodable,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>,
		examples: inout OpenAPI.Example.Map
	) throws -> OpenAPI.Content {
		try OpenAPI.Content(
			schema: .encode(value, into: &schemas),
			examples: [
				String.typeName(type(of: value)).rawValue: .a(.reference(example: value, into: &examples)),
			]
		)
	}

	static func decode(
		_ type: Decodable.Type,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Content {
		try OpenAPI.Content(
			schema: .decode(type, into: &schemas),
			examples: [:]
		)
	}
}

public extension JSONReference<OpenAPI.Example> {

	static func reference(
		example value: Encodable,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		into examples: inout OpenAPI.Example.Map
	) throws -> Self {
		let encoder = AnyValueEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		let example = try encoder.encode(value)
		let typeName = String.typeName(type(of: value)).rawValue
		var name = typeName
		var i = 0
		while let current = examples[name]?.b?.value.b, current != example {
			i += 1
			name = "\(typeName)\(i)"
		}
		examples[name] = .b(OpenAPI.Example(value: .b(example)))
		return .internal(.component(name: name))
	}
}
