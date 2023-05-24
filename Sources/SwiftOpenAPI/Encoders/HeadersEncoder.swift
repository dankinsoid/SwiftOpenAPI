import Foundation

struct HeadersEncoder {

	var dateFormat: DateEncodingFormat

	@discardableResult
	func encode(
		_ value: Encodable,
		schemas: inout [String: ReferenceOr<SchemaObject>]
	) throws -> [String: HeaderObject] {
		try parse(
			value: TypeRevision().describeType(of: value),
			type: type(of: value),
			into: &schemas
		)
	}

	@discardableResult
	func decode(
		_ type: Decodable.Type,
		schemas: inout [String: ReferenceOr<SchemaObject>]
	) throws -> [String: HeaderObject] {
		try parse(
			value: TypeRevision().describe(type: type),
			type: type,
			into: &schemas
		)
	}

	private func parse(
		value: CodableContainerValue,
		type: Any.Type,
		into schemas: inout [String: ReferenceOr<SchemaObject>]
	) throws -> [String: HeaderObject] {
		switch type {
		case is URL.Type:
			throw InvalidType()

		default:
			switch value {
			case .single, .unkeyed, .recursive:
				throw InvalidType()

			case let .keyed(keyedInfo):
				return try keyedInfo.fields.mapValues {
					try HeaderObject(
						required: !$0.isOptional,
						schema: SchemeEncoder(dateFormat: dateFormat)
							.parse(value: $0.container, type: $0.type, into: &schemas),
						example: $0.container.anyValue
					)
				}
				.with(description: (type as? OpenAPIDescriptable.Type)?.openAPIDescription)
			}
		}
	}
}
