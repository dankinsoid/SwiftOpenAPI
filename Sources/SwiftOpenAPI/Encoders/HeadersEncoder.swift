import Foundation

struct HeadersEncoder {

	var dateFormat: DateEncodingFormat
	var keyEncodingStrategy: KeyEncodingStrategy

	@discardableResult
	func encode(
		_ value: Encodable,
		schemas: inout OrderedDictionary<String, ReferenceOr<SchemaObject>>
	) throws -> OrderedDictionary<String, HeaderObject> {
		try parse(
			value: TypeRevision().describeType(of: value),
			type: type(of: value),
			into: &schemas
		)
	}

	@discardableResult
	func decode(
		_ type: Decodable.Type,
		schemas: inout OrderedDictionary<String, ReferenceOr<SchemaObject>>
	) throws -> OrderedDictionary<String, HeaderObject> {
		try parse(
			value: TypeRevision().describe(type: type),
			type: type,
			into: &schemas
		)
	}

	private func parse(
		value: TypeInfo,
		type: Any.Type,
		into schemas: inout OrderedDictionary<String, ReferenceOr<SchemaObject>>
	) throws -> OrderedDictionary<String, HeaderObject> {
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
						try HeaderObject(
							required: !$0.isOptional,
							schema: SchemeEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
								.parse(value: $0, type: $0.type, into: &schemas),
							example: $0.container.anyValue
						)
					}
					.with(description: (type as? OpenAPIDescriptable.Type)?.openAPIDescription)
			}
		}
	}
}
