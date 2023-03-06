import Foundation

struct SchemeEncoder {
    
    var extractReferences = true
    var dateFormat: DateEncodingFormat
    
    @discardableResult
    func encode(
        _ value: Encodable,
        into schemas: inout [String: ReferenceOr<SchemaObject>]
    ) throws -> ReferenceOr<SchemaObject> {
        let type = Swift.type(of: value)
       	return try parse(
            value: TypeRevision().describeType(of: value),
            type: type,
            into: &schemas
        )
    }
    
    func parse(
        value: CodableContainerValue,
        type: Any.Type,
        into schemas: inout [String: ReferenceOr<SchemaObject>]
    ) throws -> ReferenceOr<SchemaObject> {
        let name = String.typeName(type)
        let result: ReferenceOr<SchemaObject>
        
        switch type {
        case is Date.Type:
            result = .value(.primitive(.string, format: dateFormat.dataFormat))
            
        case is URL.Type:
            result = .value(.primitive(.string, format: .uri))
            
        case is Data.Type:
            result = .value(.primitive(.string, format: .binary))
            
        case let openAPI as OpenAPIType.Type:
            result = .value(openAPI.openAPISchema)
            
        default:
            switch value {
            case .single(let codableValues):
                let dataType = try parse(value: codableValues)
                if let iterable = type as? any CaseIterable.Type {
                    let allCases = iterable.allCases as any Collection
                    result = .value(.enum(dataType, allCases: allCases.map { "\($0)" }))
                } else {
                    result = .value(.primitive(dataType))
                }
                
            case .keyed(let keyedInfo):
                switch keyedInfo.isFixed {
                case true:
                    let schema = try SchemaObject.object(
                        keyedInfo.fields.mapValues {
                            try parse(value: $0.container, type: $0.type, into: &schemas)
                        }.nilIfEmpty,
                        required: Set(keyedInfo.fields.filter { !$0.value.isOptional }.keys).nilIfEmpty
                    )
                    result = .value(schema)
                    
                case false:
                    let schema = try SchemaObject.object(
                        nil,
                        required: nil,
                        additionalProperties: (keyedInfo.fields.first?.value).map {
                            try parse(value: $0.container, type: $0.type, into: &schemas)
                        }
                    )
                    result = .value(schema)
                }
                
            case .unkeyed(let typeInfo):
                let schema = try SchemaObject.array(
                    parse(value: typeInfo.container, type: typeInfo.type, into: &schemas)
                )
                result = .value(schema)
                
            case .recursive:
                result = .ref(components: \.schemas, name)
            }
        }
        
        
        if extractReferences, result.isReferenceable {
            schemas[name] = result
            return .ref(components: \.schemas, name)
        } else {
            return result
        }
    }
    
    private func parse(
        value: CodableValues
    ) throws -> PrimitiveDataType {
        switch value {
        case .int, .int8, .int16, .int32, .int64, .uint, .uint8, .uint16, .uint32, .uint64:
            return .integer
        case .double, .float:
            return .number
        case .bool:
            return .boolean
        case .string:
            return .string
        case .null:
            return .string
        }
    }
}
