import Foundation

final class SchemeDecoder: Decoder {
    
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
    
		func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = SchemeKeyedDecodingContainer<Key>(
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
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        SchemeSingleValueDecodingContainer(
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
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SchemeSingleValueDecodingContainer(
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
    func decode(_ type: Decodable.Type, into schemas: inout [String: ReferenceOr<SchemaObject>]) throws -> Decodable {
        switch type {
        case is Date.Type:
            result = .value(.primitive(.string, format: dateFormat.dataFormat))
            return Date()
            
        case is URL.Type:
            result = .value(.primitive(.string, format: .uri))
            return URL(fileURLWithPath: "File")
            
        case is Data.Type:
            result = .value(.primitive(.string, format: .binary))
            return Data()
            
        default:
            break
        }
        
        let decodable = try? type.init(from: self)
        
        if let scheme = (type as? OpenAPIType.Type)?.openAPISchema {
            result = .value(scheme)
        } else {
            schemas.merge(references) { _, new in new }
            
            switch (result, type) {
            case let (.value(.object(properties, _, _, xml)), _):
                let decoder = CheckAllKeysDecoder()
                _ = try? type.init(from: decoder)
                if decoder.isAdditional, let property = properties?.first?.value {
                    result = .value(.object(nil, required: nil, additionalProperties: property, xml: xml))
                }
                
            case let (.value(.primitive(dataType, _, _)), iterable as any CaseIterable.Type):
                let allCases = iterable.allCases as any Collection
                result = .value(.enum(dataType, allCases: allCases.map { "\($0)" }))
                guard let value = decodable ?? (allCases.first as? Decodable) else {
                    throw AnyError()
                }
                return value
                
            default:
                break
            }
        }
        
        if extractReferences, result.isReferenceable, isReferenceable(type: type) {
            let name = String.typeName(type)
            schemas[name] = result
            result = .ref(components: \.schemas, name)
        }
        guard let value = decodable else {
            throw AnyError()
        }
        return value
    }
    
    private func isReferenceable(type: Any.Type) -> Bool {
        (type as? OpenAPIType.Type)?.isPrimitive != true
    }
}

private struct SchemeSingleValueDecodingContainer: SingleValueDecodingContainer, UnkeyedDecodingContainer {

    
    var count: Int? { 1 }
    var isAtEnd: Bool { currentIndex == 1 }
    var currentIndex: Int {
        result == .value(.any) && `required` ? 0 : 1
    }
    let isSingle: Bool
    var codingPath: [CodingKey]
    @Ref var result: ReferenceOr<SchemaObject>
    @Ref var required: Bool
    let extractReferences: Bool
    let dateFormat: DateEncodingFormat
    @Ref var references: [String: ReferenceOr<SchemaObject>]
    
    func decodeNil() -> Bool {
        required = false
        return false
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        result = .value(.primitive(.boolean))
        return true
    }
    
    func decode(_ type: String.Type) throws -> String {
        result = .value(.primitive(.string))
        return ""
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        result = .value(.primitive(.number))
        return 0
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        result = .value(.primitive(.number))
        return 0
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        result = .value(.primitive(.integer))
        return 0
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        result = .value(.primitive(.integer))
        return 0
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        result = .value(.primitive(.integer))
        return 0
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        result = .value(.primitive(.integer))
        return 0
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        result = .value(.primitive(.integer))
        return 0
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        result = .value(.primitive(.integer))
        return 0
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        result = .value(.primitive(.integer))
        return 0
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        result = .value(.primitive(.integer))
        return 0
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        result = .value(.primitive(.integer))
        return 0
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        result = .value(.primitive(.integer))
        return 0
    }
    
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        let decoder = SchemeDecoder(
            codingPath: nestedPath,
            extractReferences: extractReferences,
            dateFormat: dateFormat
        )
        let decodable = try decoder.decode(type, into: &references)
        result = decoder.result
        guard let t = decodable as? T else {
            throw AnyError()
        }
        return t
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        result = .value(.object([:], required: []))
        let container = SchemeKeyedDecodingContainer<NestedKey>(
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
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedDecodingContainer {
        result = .value(.array(.value(.any)))
        return SchemeSingleValueDecodingContainer(
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
    
    func superDecoder() -> Decoder {
        SchemeDecoder(codingPath: codingPath, dateFormat: dateFormat)
    }
    
    private var nestedPath: [CodingKey] {
        isSingle ? codingPath : codingPath + [IntKey(intValue: 0)]
    }
}

private struct SchemeKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

    var allKeys: [Key] {
        return []
    }
    
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
    
    func contains(_ key: Key) -> Bool { true }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        required.remove(key.stringValue)
        return true
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try decode(.boolean, forKey: key, optional: false)
        return true
    }
    
    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        try decode(.boolean, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try decode(.string, forKey: key, optional: false)
        return ""
    }
    
    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        try decode(.string, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try decode(.number, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        try decode(.number, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try decode(.number, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        try decode(.number, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try decode(.integer, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        try decode(.integer, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try decode(.integer, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        try decode(.integer, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try decode(.integer, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        try decode(.integer, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try decode(.integer, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        try decode(.integer, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try decode(.integer, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        try decode(.integer, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try decode(.integer, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        try decode(.integer, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try decode(.integer, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        try decode(.integer, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try decode(.integer, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        try decode(.integer, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try decode(.integer, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        try decode(.integer, forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try decode(.integer, forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        try decode(.integer, forKey: key, optional: true)
        return nil
    }
    
    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        try decode(type, forKey: key, optional: false)
    }
    
    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
        try decode(type, forKey: key, optional: true)
    }
    
    private func decode<T: Decodable>(_ type: T.Type, forKey key: Key, optional: Bool) throws -> T {
        let decoder = SchemeDecoder(codingPath: nestedPath(for: key), dateFormat: dateFormat)
        let stringKey = str(key)
        let decodable = try decoder.decode(type, into: &references)
        result[stringKey] = decoder.result
        if optional {
            required.remove(stringKey)
        } else {
            required.insert(stringKey)
        }
        guard let t = decodable as? T else {
            throw AnyError()
        }
        return t
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let strKey = str(key)
        let container = SchemeKeyedDecodingContainer<NestedKey>(
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
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedDecodingContainer {
        let strKey = str(key)
        let container = SchemeSingleValueDecodingContainer(
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
    
    func superDecoder() -> Decoder {
        SchemeDecoder(codingPath: codingPath, extractReferences: extractReferences, dateFormat: dateFormat)
    }
    
    func superDecoder(forKey key: Key) -> Decoder {
        result[str(key)] = .value(.array(.value(.any)))
        return SchemeDecoder(codingPath: nestedPath(for: key), extractReferences: extractReferences, dateFormat: dateFormat)
    }
    
    private func nestedPath(for key: Key) -> [CodingKey] {
        codingPath + [key]
    }
    
    @inline(__always)
    private func decode(_ type: PrimitiveDataType, forKey key: Key, optional: Bool) throws {
        let stringKey = str(key)
        result[stringKey] = .value(.primitive(type))
        if optional {
            required.remove(stringKey)
        } else {
            required.insert(stringKey)
        }
    }
}

private struct AnyError: Error {
}

final class CheckAllKeysDecoder: Decoder {
    
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var isAdditional = false
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        KeyedDecodingContainer(
            CheckAllKeysDecodingContainer(isAdditional: Ref(self, \.isAdditional))
        )
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer { throw AnyError() }
    func singleValueContainer() throws -> SingleValueDecodingContainer { throw AnyError() }
}

private struct CheckAllKeysDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    
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
