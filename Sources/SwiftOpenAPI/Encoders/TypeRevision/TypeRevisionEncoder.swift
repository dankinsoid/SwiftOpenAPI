import Foundation

final class TypeRevisionEncoder: Encoder {
    
    var path: [TypePath]
    var codingPath: [CodingKey] { path.map(\.key) }
    var userInfo: [CodingUserInfoKey: Any]
    var result: TypeInfo
    var context: TypeRevision
    
    init(
        path: [TypePath] = [],
        context: TypeRevision
    ) {
        self.path = path
        self.context = context
        self.userInfo = [:]
        self.result = TypeInfo(type: Any.self, isOptional: false, container: .single(.null))
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = TypeRevisionKeyedEncodingContainer<Key>(
            path: path,
            encoder: self,
            result: Ref(self, \.result.container.keyed)
        )
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        TypeRevisionSingleValueEncodingContainer(
            isSingle: false,
            path: path,
            encoder: self,
            result: Ref { [self] in
                result.container.unkeyed ?? .any
            } set: { [self] newValue in
                result.container = .unkeyed(newValue)
            }
        )
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        TypeRevisionSingleValueEncodingContainer(
            isSingle: true,
            path: path,
            encoder: self,
            result: Ref(self, \.result)
        )
    }
    
    @discardableResult
    func encode(_ value: Encodable?, type: Encodable.Type) throws -> TypeInfo {
        if path.contains(where: { path in path.type == type }) {
            result.container = .recursive
        } else if let container = context.customDescription(type, value) {
        		result = TypeInfo(type: type, isOptional: value == nil, container: container)
        } else if let value {
            try value.encode(to: self)
            if case .keyed = result.container, let decodable = type as? Decodable.Type {
                let decoder = CheckAllKeysDecoder()
                _ = try? decodable.init(from: decoder)
                result.container.keyed.isFixed = !decoder.isAdditional
            }
        } else if let decodable = type as? Decodable.Type {
            let decoder = TypeRevisionDecoder(path: path, context: context)
            _ = try? decoder.decode(decodable)
            result = decoder.result
        } else {
            result.container = .single(.null)
        }
        result.type = type
        return result
    }
}

private struct TypeRevisionSingleValueEncodingContainer: SingleValueEncodingContainer, UnkeyedEncodingContainer {
    
    var count: Int { 1 }
    let isSingle: Bool
    var path: [TypePath]
    var codingPath: [CodingKey] { path.map(\.key) }
    var encoder: TypeRevisionEncoder
    @Ref var result: TypeInfo
    
    mutating func encodeNil() throws {
        result.isOptional = true
    }
    
    mutating func encode(_ value: Bool) throws {
        result = TypeInfo(type: Bool.self, container: .single(.bool(value)))
    }
    
    mutating func encode(_ value: String) throws {
        result = TypeInfo(type: String.self, container: .single(.string(value)))
    }
    
    mutating func encode(_ value: Double) throws {
        result = TypeInfo(type: Double.self, container: .single(.double(value)))
    }
    
    mutating func encode(_ value: Float) throws {
        result = TypeInfo(type: Float.self, container: .single(.float(value)))
    }
    
    mutating func encode(_ value: Int) throws {
        result = TypeInfo(type: Int.self, container: .single(.int(value)))
    }
    
    mutating func encode(_ value: Int8) throws {
        result = TypeInfo(type: Int8.self, container: .single(.int8(value)))
    }
    
    mutating func encode(_ value: Int16) throws {
        result = TypeInfo(type: Int16.self, container: .single(.int16(value)))
    }
    
    mutating func encode(_ value: Int32) throws {
        result = TypeInfo(type: Int32.self, container: .single(.int32(value)))
    }
    
    mutating func encode(_ value: Int64) throws {
        result = TypeInfo(type: Int64.self, container: .single(.int64(value)))
    }
    
    mutating func encode(_ value: UInt) throws {
        result = TypeInfo(type: UInt.self, container: .single(.uint(value)))
    }
    
    mutating func encode(_ value: UInt8) throws {
        result = TypeInfo(type: UInt8.self, container: .single(.uint8(value)))
    }
    
    mutating func encode(_ value: UInt16) throws {
        result = TypeInfo(type: UInt16.self, container: .single(.uint16(value)))
    }
    
    mutating func encode(_ value: UInt32) throws {
        result = TypeInfo(type: UInt32.self, container: .single(.uint32(value)))
    }
    
    mutating func encode(_ value: UInt64) throws {
        result = TypeInfo(type: UInt64.self, container: .single(.uint64(value)))
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        result = try TypeRevisionEncoder(
            path: nestedPath(for: T.self),
            context: encoder.context
        )
        .encode(value, type: T.self)
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        result.container = .keyed(KeyedInfo())
        let container = TypeRevisionKeyedEncodingContainer<NestedKey>(
            path: nestedPath(for: [String: Any].self),
            encoder: encoder,
            result: Ref(self, \.result.container.keyed)
        )
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        result.container = .unkeyed(.any)
        return TypeRevisionSingleValueEncodingContainer(
            isSingle: false,
            path: nestedPath(for: [Any].self),
            encoder: encoder,
            result: Ref { [$result] in
                return $result.wrappedValue.container.unkeyed ?? .any
            } set: { [$result] newValue in
                $result.wrappedValue.container.unkeyed = newValue
            }
        )
    }
    
    mutating func superEncoder() -> Encoder {
        TypeRevisionEncoder(path: path, context: encoder.context)
    }
    
    private func nestedPath(for type: Any.Type) -> [TypePath] {
        isSingle ? path : path + [TypePath(type: type, key: IntKey(intValue: count))]
    }
}

private struct TypeRevisionKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    
    var path: [TypePath]
    var codingPath: [CodingKey] { path.map(\.key) }
    var encoder: TypeRevisionEncoder
    @Ref var result: KeyedInfo
    
    @inline(__always)
    private func str(_ key: Key) -> String {
        key.stringValue
    }
    
    mutating func encodeNil(forKey key: Key) throws {
        result[str(key)].isOptional = true
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        try encode(.bool(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
        try encode(.bool(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        try encode(.string(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: String?, forKey key: Key) throws {
        try encode(.string(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        try encode(.double(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
        try encode(.double(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        try encode(.float(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
        try encode(.float(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        try encode(.int(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
        try encode(.int(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        try encode(.int8(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
        try encode(.int8(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        try encode(.int16(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
        try encode(.int16(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        try encode(.int32(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
        try encode(.int32(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        try encode(.int64(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
        try encode(.int64(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        try encode(.uint(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
        try encode(.uint(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        try encode(.uint8(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
        try encode(.uint8(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        try encode(.uint16(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
        try encode(.uint16(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        try encode(.uint32(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
        try encode(.uint32(value), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        try encode(.uint64(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
        try encode(.uint64(value), forKey: key, optional: true)
    }
    
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        try encode(value, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
        try encode(value, forKey: key, optional: true)
    }
    
    private mutating func encode<T>(_ value: T?, forKey key: Key, optional: Bool) throws where T : Encodable {
        let encoder = TypeRevisionEncoder(
            path: nestedPath(for: key, T.self),
            context: encoder.context
        )
        var info = try encoder.encode(value, type: T.self)
        info.isOptional = optional
        info.type = T.self
        result[str(key)] = info
    }
    
    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let strKey = str(key)
        let container = TypeRevisionKeyedEncodingContainer<NestedKey>(
            path: nestedPath(for: key, [String: Any].self),
            encoder: encoder,
            result: Ref(self, \.result[strKey].container.keyed)
        )
        result[strKey].container = .keyed(KeyedInfo())
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let strKey = str(key)
        let container = TypeRevisionSingleValueEncodingContainer(
            isSingle: false,
            path: nestedPath(for: key, [Any].self),
            encoder: encoder,
            result: Ref { [$result] in
                $result.wrappedValue[strKey].container.unkeyed ?? .any
            } set: { [$result] newValue in
                $result.wrappedValue[strKey].container.unkeyed = newValue
            }
        )
        result[strKey].container = .unkeyed(.any)
        return container
    }
    
    mutating func superEncoder() -> Encoder {
        TypeRevisionEncoder(path: path, context: encoder.context)
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        TypeRevisionEncoder(path: path, context: encoder.context)
    }
    
    private func nestedPath(for key: Key, _ type: Any.Type) -> [TypePath] {
        path + [TypePath(type: type, key: key)]
    }
    
    @inline(__always)
    private mutating func encode(_ type: CodableValues, forKey key: Key, optional: Bool) throws {
        result[str(key)] = TypeInfo(type: type.type, isOptional: optional, container: .single(type))
    }
}
