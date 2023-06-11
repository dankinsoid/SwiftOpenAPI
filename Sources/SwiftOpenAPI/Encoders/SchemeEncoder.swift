import Foundation

struct SchemeEncoder {

	var extractReferences = true
	var dateFormat: DateEncodingFormat
	var keyEncodingStrategy: KeyEncodingStrategy

	@discardableResult
	func encode(
		_ value: Encodable,
		into schemas: inout ComponentsMap<SchemaObject>
	) throws -> ReferenceOr<SchemaObject> {
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
		into schemas: inout ComponentsMap<SchemaObject>
	) throws -> ReferenceOr<SchemaObject> {
		try parse(
			value: TypeRevision().describe(type: type),
			type: type,
			into: &schemas
		)
	}

	func parse(
		value: @autoclosure () throws -> TypeInfo,
		type: Any.Type,
		into schemas: inout ComponentsMap<SchemaObject>
	) throws -> ReferenceOr<SchemaObject> {
		let name = String.typeName(type)
		var result: ReferenceOr<SchemaObject>
		let typeInfo = try value()

		switch type {
		case is Date.Type:
			result = .value(dateFormat.schema)

		case let openAPI as OpenAPIType.Type:
			result = .value(openAPI.openAPISchema)

		default:
			switch typeInfo.container {
			case let .single(codableValues):
				let (dataType, format) = try parse(value: codableValues)
				let schema: SchemaObject
				if let iterable = type as? any CaseIterable.Type {
					let allCases = iterable.allCases as any Collection
					schema = .enum(of: dataType, cases: allCases.map { "\($0)" })
				} else {
					schema = SchemaObject(format: format, context: SchemaContexts(dataType))
				}
				result = .value(schema)

			case let .keyed(keyedInfo):
				switch keyedInfo.isFixed {
				case true:
					let schema = try SchemaObject.object(
						properties: keyedInfo.fields.mapKeys {
							keyEncodingStrategy.encode($0)
						}.mapValues {
							try parse(value: $0, type: $0.type, into: &schemas)
						},
						required: Set(keyedInfo.fields.unorderedHash.filter { !$0.value.isOptional }.keys)
					)
					result = .value(schema)

				case false:
					let schema = try SchemaObject.dictionary(
						of: (keyedInfo.fields.first?.value).map {
							try parse(value: $0, type: $0.type, into: &schemas)
						} ?? .any
					)
					result = .value(schema)
				}

			case let .unkeyed(itemInfo):
				let schema = try SchemaObject.array(
					of: parse(value: itemInfo, type: itemInfo.type, into: &schemas)
				)
				result = .value(schema)

			case .recursive:
				result = .ref(components: \.schemas, name)
			}
		}

		if let descriptable = type as? OpenAPIDescriptable.Type {
			result = result.with(description: descriptable.openAPIDescription)
		}

		if extractReferences, result.isReferenceable {
			result.object?.nullable = nil
			schemas[name] = result
			return .ref(components: \.schemas, name)
		} else {
			if typeInfo.isOptional, result.object?.enum == nil {
				result.object?.nullable = true
			}
			return result
		}
	}

	private func parse(
		value: CodableValues
	) throws -> (PrimitiveDataType, DataFormat?) {
		switch value {
		case .int8, .int16, .int32, .uint8, .uint16, .uint32:
			return (.integer, .int32)
		case .int, .int64, .uint, .uint64:
			return (.integer, .int64)
		case .double:
			return (.number, .double)
		case .float:
			return (.number, .float)
		case .bool:
			return (.boolean, nil)
		case .string, .null:
			return (.string, nil)
		}
	}
}
