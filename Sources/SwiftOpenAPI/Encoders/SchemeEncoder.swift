import Foundation

final class SchemeEncoder: Encoder {
    
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    var result: SchemaObject
    var required: Bool
    var references: [String: ReferenceOr<SchemaObject>]
    var extractReferences: Bool
    
    init(codingPath: [CodingKey] = [], extractReferences: Bool = true) {
        self.codingPath = codingPath
        self.userInfo = [:]
        self.result = .any
        self.required = true
        self.references = [:]
        self.extractReferences = extractReferences
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = SchemeKeyedEncodingContainer<Key>(
            codingPath: codingPath,
            result: Ref { [self] in
                guard
                    case let .object(properties, _, _, _) = result
                else { return [:] }
                return properties ?? [:]
            } set: { [self] newValue in
                switch result {
                case let .object(_, required, additionalProperties, xml):
                    result = .object(newValue, required: required, additionalProperties: additionalProperties, xml: xml)
                default:
                    result = .object(newValue, required: [])
                }
            },
            required: Ref { [self] in
                guard
                    case let .object(_, required, _, _) = result
                else { return [] }
                return required ?? []
            } set: { [self] newValue in
                switch result {
                case let .object(properties, _, additionalProperties, xml):
                    result = .object(properties, required: newValue, additionalProperties: additionalProperties, xml: xml)
                default:
                    result = .object([:], required: newValue)
                }
            },
            extractReferences: extractReferences,
            references: Ref(self, \.references)
        )
        result = .object([:], required: [])
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        result = .array(.value(.any))
        return SchemeSingleValueEncodingContainer(
            isSingle: false,
            codingPath: codingPath,
            result: Ref { [self] in
                if case let .array(value) = result {
                    return value
                }
                return .value(.any)
            } set: { [self] newValue in
                result = .array(newValue)
            },
            required: .constant(true),
            extractReferences: extractReferences,
            references: Ref(self, \.references)
        )
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        result = .any
        return SchemeSingleValueEncodingContainer(
            isSingle: true,
            codingPath: codingPath,
            result: Ref { [self] in
                .value(result)
            } set: { [self] newValue in
                if case let .value(value) = newValue {
                    result = value
                }
            },
            required: Ref(self, \.required),
            extractReferences: extractReferences,
            references: Ref(self, \.references)
        )
    }
}

private struct SchemeSingleValueEncodingContainer: SingleValueEncodingContainer, UnkeyedEncodingContainer {
    
    var count: Int { 1 }
    let isSingle: Bool
    var codingPath: [CodingKey]
    @Ref var result: ReferenceOr<SchemaObject>
    @Ref var required: Bool
    let extractReferences: Bool
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
        let encoder = SchemeEncoder(
            codingPath: nestedPath,
            extractReferences: extractReferences
        )
        try value.encode(to: encoder)
        references.merge(encoder.references) { _, s in s }
        if extractReferences, encoder.result.isReferenceable {
            let name = String.typeName(T.self)
            references[name] = .value(encoder.result)
            result = .ref(components: \.schemas, name)
        } else {
            result = .value(encoder.result)
        }
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
                    $result.wrappedValue = .value(.object(newValue, required: required, additionalProperties: additionalProperties, xml: xml))
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
                    $result.wrappedValue = .value(.object(properties, required: newValue, additionalProperties: additionalProperties, xml: xml))
                default:
                    $result.wrappedValue = .value(.object([:], required: newValue))
                }
            },
            extractReferences: extractReferences,
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
            references: $references
        )
    }
    
    mutating func superEncoder() -> Encoder {
        SchemeEncoder(codingPath: codingPath)
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
        let encoder = SchemeEncoder(codingPath: nestedPath(for: key))
        try value.encode(to: encoder)
        references.merge(encoder.references) { _, s in s }
        let stringKey = str(key)
        if extractReferences, encoder.result.isReferenceable {
            let name = String.typeName(T.self)
            references[name] = .value(encoder.result)
            result[stringKey] = .ref(components: \.schemas, name)
        } else {
            result[stringKey] = .value(encoder.result)
        }
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
            references: $references
        )
        result[strKey] = .value(.array(.value(.any)))
        return container
    }
    
    mutating func superEncoder() -> Encoder {
        SchemeEncoder(codingPath: codingPath, extractReferences: extractReferences)
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        result[str(key)] = .value(.array(.value(.any)))
        return SchemeEncoder(codingPath: nestedPath(for: key), extractReferences: extractReferences)
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
