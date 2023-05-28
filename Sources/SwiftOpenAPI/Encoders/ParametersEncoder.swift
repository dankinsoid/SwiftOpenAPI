import Foundation

struct ParametersEncoder {

	var location: ParameterObject.Location
	var dateFormat: DateEncodingFormat
	var keyEncodingStrategy: KeyEncodingStrategy

	@discardableResult
	func encode(
		_ value: Encodable,
		schemas: inout [String: ReferenceOr<SchemaObject>]
	) throws -> [ParameterObject] {
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
	) throws -> [ParameterObject] {
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
	) throws -> [ParameterObject] {
		switch type {
		case is URL.Type:
			throw InvalidType()

		default:
			switch value {
			case .single, .unkeyed, .recursive:
				throw InvalidType()

			case let .keyed(keyedInfo):
				return try keyedInfo.fields.map {
					try ParameterObject(
						name: keyEncodingStrategy.encode($0.key),
						in: location,
						required: !$0.value.isOptional,
						schema: SchemeEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
							.parse(value: $0.value.container, type: $0.value.type, into: &schemas),
						example: $0.value.container.anyValue
					)
				}
				.sorted { $0.name < $1.name }
				.with(description: (type as? OpenAPIDescriptable.Type)?.openAPIDescription)
			}
		}
	}
}

struct InvalidType: Error {}
