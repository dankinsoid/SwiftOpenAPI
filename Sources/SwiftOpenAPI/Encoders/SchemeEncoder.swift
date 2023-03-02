import Foundation

final class SchemeEncoder: Encoder {
    
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    var result: ReferenceOr<SchemaObject>
    var required: Bool
    var references: [String: ReferenceOr<SchemaObject>]
    var extractReferences: Bool
    var dateFormat: DateEncodingFormat
    
    init(
        codingPath: [CodingKey] = [],
        extractReferences: Bool = true,
        dateFormat: DateEncodingFormat
    ) {
        self.codingPath = codingPath
        self.userInfo = [:]
        self.result = .value(.any)
        self.required = true
        self.references = [:]
        self.extractReferences = extractReferences
        self.dateFormat = dateFormat
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = SchemeKeyedEncodingContainer<Key>(
            codingPath: codingPath,
            result: Ref { [self] in
                guard
                    case let .value(.object(properties, _, _, _)) = result
                else { return [:] }
                return properties ?? [:]
            } set: { [self] newValue in
                switch result {
                case let .value(.object(_, required, additionalProperties, xml)):
                    result = .value(.object(newValue, required: required, additionalProperties: additionalProperties, xml: xml))
                default:
                    result = .value(.object(newValue, required: []))
                }
            },
            required: Ref { [self] in
                guard
                    case let .value(.object(_, required, _, _)) = result
                else { return [] }
                return required ?? []
            } set: { [self] newValue in
                switch result {
                case let .value(.object(properties, _, additionalProperties, xml)):
                    result = .value(.object(properties, required: newValue, additionalProperties: additionalProperties, xml: xml))
                default:
                    result = .value(.object([:], required: newValue))
                }
            },
            extractReferences: extractReferences,
            dateFormat: dateFormat,
            references: Ref(self, \.references)
        )
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        SchemeSingleValueEncodingContainer(
            isSingle: false,
            codingPath: codingPath,
            result: Ref { [self] in
                if case let .value(.array(value)) = result {
                    return value
                }
                return .value(.any)
            } set: { [self] newValue in
                result = .value(.array(newValue))
            },
            required: .constant(true),
            extractReferences: extractReferences,
            dateFormat: dateFormat,
            references: Ref(self, \.references)
        )
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        SchemeSingleValueEncodingContainer(
            isSingle: true,
            codingPath: codingPath,
            result: Ref(self, \.result),
            required: Ref(self, \.required),
            extractReferences: extractReferences,
            dateFormat: dateFormat,
            references: Ref(self, \.references)
        )
    }
    
    @discardableResult
    func encode(_ value: Encodable, into schemas: inout [String: ReferenceOr<SchemaObject>]) throws -> ReferenceOr<SchemaObject> {
        switch value {
        case is Date:
            result = .value(.primitive(.string, format: dateFormat.dataFormat))
            return result
            
        case is URL:
            result = .value(.primitive(.string, format: .uri))
            return result
            
        case is Data:
            result = .value(.primitive(.string, format: .binary))
            return result
            
        default:
            break
        }
        
        let type = type(of: value)
        
        if let scheme = (type as? OpenAPIType.Type)?.openAPISchema {
            result = .value(scheme)
        } else {
            try value.encode(to: self)
            schemas.merge(references) { _, new in new }
            
            switch (result, type) {
            case let (.value(.object(properties, _, _, xml)), decodable as Decodable.Type):
                let decoder = SchemeDecoder()
                _ = try? decodable.init(from: decoder)
                if decoder.isAdditional, let property = properties?.first?.value {
                    result = .value(.object(nil, required: nil, additionalProperties: property, xml: xml))
                }
                
            case let (.value(.primitive(dataType, _, _)), iterable as any CaseIterable.Type):
                let allCases = iterable.allCases as any Collection
                result = .value(.enum(dataType, allCases: allCases.map { "\($0)" }))
                
            default:
                break
            }
        }
        
        if extractReferences, result.isReferenceable, isReferenceable(type: type) {
            let name = String.typeName(type)
            schemas[name] = result
            return .ref(components: \.schemas, name)
        } else {
            return result
        }
    }
    
    private func isReferenceable(type: Any.Type) -> Bool {
        (type as? OpenAPIType.Type)?.isPrimitive != true
    }
}

private struct SchemeSingleValueEncodingContainer: SingleValueEncodingContainer, UnkeyedEncodingContainer {
    
    var count: Int { 1 }
    let isSingle: Bool
    var codingPath: [CodingKey]
    @Ref var result: ReferenceOr<SchemaObject>
    @Ref var required: Bool
    let extractReferences: Bool
    let dateFormat: DateEncodingFormat
    @Ref var references: [String: ReferenceOr<SchemaObject>]
    
    mutating func encodeNil() throws {
        required = false
    }
    
    mutating func encode(_: Bool) throws {
        result = .value(.primitive(.boolean))
    }
    
    mutating func encode(_: String) throws {
        result = .value(.primitive(.string))
    }
    
    mutating func encode(_: Double) throws {
        result = .value(.primitive(.number))
    }
    
    mutating func encode(_: Float) throws {
        result = .value(.primitive(.number))
    }
    
    mutating func encode(_: Int) throws {
        result = .value(.primitive(.integer))
    }
    
    mutating func encode(_: Int8) throws {
        result = .value(.primitive(.integer))
    }
    
    mutating func encode(_: Int16) throws {
        result = .value(.primitive(.integer))
    }
    
    mutating func encode(_: Int32) throws {
        result = .value(.primitive(.integer))
    }
    
    mutating func encode(_: Int64) throws {
        result = .value(.primitive(.integer))
    }
    
    mutating func encode(_: UInt) throws {
        result = .value(.primitive(.integer))
    }
    
    mutating func encode(_: UInt8) throws {
        result = .value(.primitive(.integer))
    }
    
    mutating func encode(_: UInt16) throws {
        result = .value(.primitive(.integer))
    }
    
    mutating func encode(_: UInt32) throws {
        result = .value(.primitive(.integer))
    }
    
    mutating func encode(_: UInt64) throws {
        result = .value(.primitive(.integer))
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        result = try SchemeEncoder(
            codingPath: nestedPath,
            extractReferences: extractReferences,
            dateFormat: dateFormat
        )
        .encode(value, into: &references)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        result = .value(.object([:], required: []))
        let container = SchemeKeyedEncodingContainer<NestedKey>(
            codingPath: nestedPath,
            result: Ref { [$result] in
                guard
                    case let .value(.object(properties, _, _, _)) = $result.wrappedValue
                else { return [:] }
                return properties ?? [:]
            } set: { [$result] newValue in
                switch $result.wrappedValue {
                case let .value(.object(_, required, additionalProperties, xml)):
                    $result.wrappedValue = .value(
                        .object(newValue, required: required, additionalProperties: additionalProperties, xml: xml)
                    )
                default:
                    $result.wrappedValue = .value(.object(newValue, required: []))
                }
            },
            required: Ref { [$result] in
                guard
                    case let .value(.object(_, required, _, _)) = $result.wrappedValue
                else { return [] }
                return required ?? []
            } set: { [$result] newValue in
                switch $result.wrappedValue {
                case let .value(.object(properties, _, additionalProperties, xml)):
                    $result.wrappedValue = .value(
                        .object(properties, required: newValue, additionalProperties: additionalProperties, xml: xml)
                    )
                default:
                    $result.wrappedValue = .value(.object([:], required: newValue))
                }
            },
            extractReferences: extractReferences,
            dateFormat: dateFormat,
            references: $references
        )
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        result = .value(.array(.value(.any)))
        return SchemeSingleValueEncodingContainer(
            isSingle: false,
            codingPath: nestedPath,
            result: Ref { [$result] in
                guard
                    case let .value(.array(value)) = $result.wrappedValue
                else { return .value(.any) }
                return value
            } set: { [$result] newValue in
                $result.wrappedValue = .value(.array(newValue))
            },
            required: .constant(true),
            extractReferences: extractReferences,
            dateFormat: dateFormat,
            references: $references
        )
    }
    
    mutating func superEncoder() -> Encoder {
        SchemeEncoder(codingPath: codingPath, dateFormat: dateFormat)
    }
    
    private var nestedPath: [CodingKey] {
        isSingle ? codingPath : codingPath + [IntKey(intValue: count)]
    }
}

private struct SchemeKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    
    var codingPath: [CodingKey]
    @Ref var result: [String: ReferenceOr<SchemaObject>]
    @Ref var required: Set<String>
    let extractReferences: Bool
    let dateFormat: DateEncodingFormat
    @Ref var references: [String: ReferenceOr<SchemaObject>]
    
    @inline(__always)
    private func str(_ key: Key) -> String {
        key.stringValue
    }
    
    mutating func encodeNil(forKey key: Key) throws {
        required.remove(key.stringValue)
    }
    
    mutating func encode(_: Bool, forKey key: Key) throws {
        try encode(.boolean, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_: Bool?, forKey key: Key) throws {
        try encode(.boolean, forKey: key, optional: true)
    }
    
    mutating func encode(_: String, forKey key: Key) throws {
        try encode(.string, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: String?, forKey key: Key) throws {
        try encode(.string, forKey: key, optional: true)
    }
    
    mutating func encode(_: Double, forKey key: Key) throws {
        try encode(.number, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
        try encode(.number, forKey: key, optional: true)
    }
    
    mutating func encode(_: Float, forKey key: Key) throws {
        try encode(.number, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
        try encode(.number, forKey: key, optional: true)
    }
    
    mutating func encode(_: Int, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: true)
    }
    
    mutating func encode(_: Int8, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: true)
    }
    
    mutating func encode(_: Int16, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: true)
    }
    
    mutating func encode(_: Int32, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: true)
    }
    
    mutating func encode(_: Int64, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: true)
    }
    
    mutating func encode(_: UInt, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: true)
    }
    
    mutating func encode(_: UInt8, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: true)
    }
    
    mutating func encode(_: UInt16, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: true)
    }
    
    mutating func encode(_: UInt32, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: true)
    }
    
    mutating func encode(_: UInt64, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
        try encode(.integer, forKey: key, optional: true)
    }
    
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        try encode(value, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
        try encode(value, forKey: key, optional: true)
    }
    
    private mutating func encode<T>(_ value: T?, forKey key: Key, optional: Bool) throws where T : Encodable {
        let encoder = SchemeEncoder(codingPath: nestedPath(for: key), dateFormat: dateFormat)
        let stringKey = str(key)
        result[stringKey] = value.flatMap { try? encoder.encode($0, into: &references) }
        if optional {
            required.remove(stringKey)
        } else {
            required.insert(stringKey)
        }
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let strKey = str(key)
        let container = SchemeKeyedEncodingContainer<NestedKey>(
            codingPath: nestedPath(for: key),
            result: Ref { [$result] in
                guard
                    case let .value(.object(properties, _, _, _)) = $result.wrappedValue[strKey]
                else { return [:] }
                return properties ?? [:]
            } set: { [$result] newValue in
                switch $result.wrappedValue[strKey] {
                case let .value(.object(_, required, additional, xml)):
                    $result.wrappedValue[strKey] = .value(
                        .object(newValue, required: required, additionalProperties: additional, xml: xml)
                    )
                    
                default:
                    $result.wrappedValue[strKey] = .value(.object(newValue, required: nil))
                }
            },
            required: Ref { [$result] in
                guard
                    case let .value(.object(_, required, _, _)) = $result.wrappedValue[strKey]
                else { return [] }
                return required ?? []
            } set: { [$result] newValue in
                switch $result.wrappedValue[strKey] {
                case let .value(.object(properties, _, additional, xml)):
                    $result.wrappedValue[strKey] = .value(
                        .object(properties, required: newValue, additionalProperties: additional, xml: xml)
                    )
                    
                default:
                    $result.wrappedValue[strKey] = .value(.object([:], required: newValue))
                }
            },
            extractReferences: extractReferences,
            dateFormat: dateFormat,
            references: $references
        )
        result[strKey] = .value(.object([:], required: []))
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let strKey = str(key)
        let container = SchemeSingleValueEncodingContainer(
            isSingle: false,
            codingPath: nestedPath(for: key),
            result: Ref { [$result] in
                guard
                    case let .value(.array(value)) = $result.wrappedValue[strKey]
                else { return .value(.array(.value(.any))) }
                return value
            } set: { [$result] newValue in
                $result.wrappedValue[strKey] = .value(.array(newValue))
            },
            required: .constant(true),
            extractReferences: extractReferences,
            dateFormat: dateFormat,
            references: $references
        )
        result[strKey] = .value(.array(.value(.any)))
        return container
    }
    
    mutating func superEncoder() -> Encoder {
        SchemeEncoder(codingPath: codingPath, extractReferences: extractReferences, dateFormat: dateFormat)
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        result[str(key)] = .value(.array(.value(.any)))
        return SchemeEncoder(codingPath: nestedPath(for: key), extractReferences: extractReferences, dateFormat: dateFormat)
    }
    
    private func nestedPath(for key: Key) -> [CodingKey] {
        codingPath + [key]
    }
    
    @inline(__always)
    private mutating func encode(_ type: PrimitiveDataType, forKey key: Key, optional: Bool) throws {
        let stringKey = str(key)
        result[stringKey] = .value(.primitive(type))
        if optional {
            required.remove(stringKey)
        } else {
            required.insert(stringKey)
        }
    }
}

private final class SchemeDecoder: Decoder {
    
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var isAdditional = false
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        KeyedDecodingContainer(
            SchemeDecodingContainer(isAdditional: Ref(self, \.isAdditional))
        )
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer { throw AnyError() }
    func singleValueContainer() throws -> SingleValueDecodingContainer { throw AnyError() }
}

private struct SchemeDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    
    var allKeys: [Key] {
        isAdditional = true
        return []
    }
    @Ref var isAdditional: Bool
    
    var codingPath: [CodingKey] { [] }
    func contains(_ key: Key) -> Bool { false }
    func decodeNil(forKey key: Key) throws -> Bool { throw AnyError() }
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { throw AnyError() }
    func decode(_ type: String.Type, forKey key: Key) throws -> String { throw AnyError() }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double { throw AnyError() }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float { throw AnyError() }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int { throw AnyError() }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { throw AnyError() }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { throw AnyError() }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { throw AnyError() }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { throw AnyError() }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { throw AnyError() }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { throw AnyError() }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { throw AnyError() }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { throw AnyError() }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { throw AnyError() }
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable { throw AnyError() }
    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> { throw AnyError() }
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer { throw AnyError() }
    func superDecoder() throws -> Decoder { throw AnyError() }
    func superDecoder(forKey key: Key) throws -> Decoder { throw AnyError() }
}

private struct AnyError: Error {
}
