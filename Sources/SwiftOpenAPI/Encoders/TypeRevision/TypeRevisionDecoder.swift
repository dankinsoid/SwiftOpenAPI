import Foundation

final class TypeRevisionDecoder: Decoder {
    
    typealias Cache = [ObjectIdentifier: (TypeInfo, Decodable)]
    
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
        self.userInfo = [:]
        self.result = .any
        self.context = context
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        result.container.keyed = KeyedInfo()
        let container = TypeRevisionKeyedDecodingContainer<Key>(
            path: path,
            decoder: self,
            result: Ref(self, \.result.container.keyed)
        )
        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        result.container.unkeyed = .any
        return TypeRevisionSingleValueDecodingContainer(
            isSingle: false,
            path: path,
            decoder: self,
            result: Ref { [self] in
                result.container.unkeyed ?? .any
            } set: { [self] newValue in
                result.container.unkeyed = newValue
            }
        )
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        var wasSetted = false
        return TypeRevisionSingleValueDecodingContainer(
            isSingle: true,
            path: path,
            decoder: self,
            result: Ref { [self] in
                wasSetted ? result : nil
            } set: { [self] newValue in
                if let newValue {
                    wasSetted = true
                    result = newValue
                }
            }
        )
    }
    
    @discardableResult
    func decode(_ type: Decodable.Type) throws -> Decodable {
        guard path.isEmpty || !path.dropLast().contains(where: { path in path.type == type }) else {
            result.container = .recursive
            result.type = type
            throw AnyError()
        }
        let decodable = try? type.init(from: self)
        if let custom = context.customDescription(type, nil) {
            result.container = custom
        } else if case .keyed = result.container {
            let decoder = CheckAllKeysDecoder()
            _ = try? type.init(from: decoder)
            result.container.keyed.isFixed = !decoder.isAdditional
        }
        guard let value = decodable else {
            if let iterable = type as? any CaseIterable.Type {
                let allCases = iterable.allCases as any Collection
                if let result = allCases.first as? Decodable {
                    return result
                }
            }
            throw AnyError()
        }
        result.type = type
        return value
    }
    
    private func isReferenceable(type: Any.Type) -> Bool {
        (type as? OpenAPIType.Type)?.isPrimitive != true
    }
}

private struct TypeRevisionSingleValueDecodingContainer: SingleValueDecodingContainer, UnkeyedDecodingContainer {
    
    var count: Int? { 1 }
    var isAtEnd: Bool { currentIndex == 1 }
    var currentIndex: Int {
        result == nil ? 0 : 1
    }
    let isSingle: Bool
    var path: [TypePath]
    var codingPath: [CodingKey] { path.map(\.key) }
    var decoder: TypeRevisionDecoder
    @Ref var result: TypeInfo?
    
    func decodeNil() -> Bool {
        result[or: .any].isOptional = true
        return false
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        result = TypeInfo(type: type, container: .single(.bool(nil)))
        return true
    }
    
    func decode(_ type: String.Type) throws -> String {
        result = TypeInfo(type: type, container: .single(.string(nil)))
        return ""
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        result = TypeInfo(type: type, container: .single(.double(nil)))
        return 0
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        result = TypeInfo(type: type, container: .single(.float(nil)))
        return 0
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        result = TypeInfo(type: type, container: .single(.int(nil)))
        return 0
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        result = TypeInfo(type: type, container: .single(.int8(nil)))
        return 0
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        result = TypeInfo(type: type, container: .single(.int16(nil)))
        return 0
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        result = TypeInfo(type: type, container: .single(.int32(nil)))
        return 0
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        result = TypeInfo(type: type, container: .single(.int64(nil)))
        return 0
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        result = TypeInfo(type: type, container: .single(.uint(nil)))
        return 0
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        result = TypeInfo(type: type, container: .single(.uint8(nil)))
        return 0
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        result = TypeInfo(type: type, container: .single(.uint16(nil)))
        return 0
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        result = TypeInfo(type: type, container: .single(.uint32(nil)))
        return 0
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        result = TypeInfo(type: type, container: .single(.uint64(nil)))
        return 0
    }
    
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        let decoder = TypeRevisionDecoder(
            path: nestedPath(for: type),
            context: decoder.context
        )
        let decodable = try? decoder.decode(type)
        var value = decoder.result
        value.type = type
        result = value
        guard let t = decodable as? T else {
            throw AnyError()
        }
        return t
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        result[or: .any].container.keyed = KeyedInfo()
        let container = TypeRevisionKeyedDecodingContainer<NestedKey>(
            path: nestedPath(for: [String: Any].self),
            decoder: decoder,
            result: Ref { [$result] in
                $result.wrappedValue[or: .any].container.keyed
            } set: { [$result] newValue in
                $result.wrappedValue[or: .any].container.keyed = newValue
            }
        )
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedDecodingContainer {
        result[or: .any].container.unkeyed = .any
        return TypeRevisionSingleValueDecodingContainer(
            isSingle: false,
            path: nestedPath(for: [Any].self),
            decoder: decoder,
            result: Ref { [$result] in
                $result.wrappedValue[or: .any].container.unkeyed ?? .any
            } set: { [$result] newValue in
                $result.wrappedValue[or: .any].container.unkeyed = newValue
            }
        )
    }
    
    func superDecoder() -> Decoder {
        TypeRevisionDecoder(path: path, context: decoder.context)
    }
    
    private func nestedPath(for type: Any.Type) -> [TypePath] {
        isSingle ? path : path + [TypePath(type: type, key: IntKey(intValue: 0))]
    }
}

private struct TypeRevisionKeyedDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
    
    var allKeys: [Key] {
        if let iterable = Key.self as? any CaseIterable.Type {
            let array = iterable.allCases as any Collection
            return Array(array.compactMap { $0 as? Key }.prefix(1))
        }
        return Key(stringValue: "").map { [$0] } ?? []
    }
    
    var path: [TypePath]
    var codingPath: [CodingKey] { path.map(\.key) }
    var decoder: TypeRevisionDecoder
    @Ref var result: KeyedInfo
    
    @inline(__always)
    private func str(_ key: Key) -> String {
        key.stringValue
    }
    
    func contains(_ key: Key) -> Bool { true }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        result[str(key)].isOptional = true
        return false
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        decode(.bool(nil), forKey: key, optional: false)
        return true
    }
    
    func decodeIfPresent(_ type: Bool.Type, forKey key: Key) throws -> Bool? {
        decode(.bool(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        decode(.string(nil), forKey: key, optional: false)
        return ""
    }
    
    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        decode(.string(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        decode(.double(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Double.Type, forKey key: Key) throws -> Double? {
        decode(.double(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        decode(.float(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Float.Type, forKey key: Key) throws -> Float? {
        decode(.float(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        decode(.int(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Int.Type, forKey key: Key) throws -> Int? {
        decode(.int(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        decode(.int8(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Int8.Type, forKey key: Key) throws -> Int8? {
        decode(.int8(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        decode(.int16(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Int16.Type, forKey key: Key) throws -> Int16? {
        decode(.int16(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        decode(.int32(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Int32.Type, forKey key: Key) throws -> Int32? {
        decode(.int32(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        decode(.int64(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: Int64.Type, forKey key: Key) throws -> Int64? {
        decode(.int64(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        decode(.uint(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: UInt.Type, forKey key: Key) throws -> UInt? {
        decode(.uint(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        decode(.uint8(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: UInt8.Type, forKey key: Key) throws -> UInt8? {
        decode(.uint8(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        decode(.uint16(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: UInt16.Type, forKey key: Key) throws -> UInt16? {
        decode(.uint16(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        decode(.uint32(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: UInt32.Type, forKey key: Key) throws -> UInt32? {
        decode(.uint32(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        decode(.uint64(nil), forKey: key, optional: false)
        return 0
    }
    
    func decodeIfPresent(_ type: UInt64.Type, forKey key: Key) throws -> UInt64? {
        decode(.uint64(nil), forKey: key, optional: true)
        return nil
    }
    
    func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        try decode(type, forKey: key, optional: false)
    }
    
    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
        try? decode(type, forKey: key, optional: true)
    }
    
    private func decode<T: Decodable>(_ type: T.Type, forKey key: Key, optional: Bool) throws -> T {
        let decoder = TypeRevisionDecoder(path: nestedPath(for: key, type), context: decoder.context)
        let decodable = try? decoder.decode(type)
        var value = decoder.result
        value.type = type
        value.isOptional = optional
        result[str(key)] = value
        guard let t = decodable as? T else {
            throw AnyError()
        }
        return t
    }
    
    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedDecodingContainer<NestedKey> {
        let strKey = str(key)
        let container = TypeRevisionKeyedDecodingContainer<NestedKey>(
            path: nestedPath(for: key, [String: Any].self),
            decoder: decoder,
            result: Ref(self, \.result[strKey].container.keyed)
        )
        result[strKey].container.keyed = KeyedInfo()
        return KeyedDecodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedDecodingContainer {
        let strKey = str(key)
        let container = TypeRevisionSingleValueDecodingContainer(
            isSingle: false,
            path: nestedPath(for: key, [Any].self),
            decoder: decoder,
            result: Ref { [$result] in
                $result.wrappedValue[strKey].container.unkeyed ?? .any
            } set: { [$result] newValue in
                $result.wrappedValue[strKey].container.unkeyed = newValue
            }
        )
        result[strKey].container.unkeyed = .any
        return container
    }
    
    func superDecoder() -> Decoder {
        TypeRevisionDecoder(path: path, context: decoder.context)
    }
    
    func superDecoder(forKey key: Key) -> Decoder {
        TypeRevisionDecoder(path: nestedPath(for: key, Any.self), context: decoder.context)
    }
    
    private func nestedPath(for key: Key, _ type: Any.Type) -> [TypePath] {
        path + [TypePath(type: type, key: key)]
    }
    
    @inline(__always)
    private func decode(_ value: CodableValues, forKey key: Key, optional: Bool) {
        result[str(key)] = TypeInfo(type: value.type, isOptional: optional, container: .single(value))
    }
}

private struct AnyError: Error {
}

private extension Optional {
    
    subscript(or value: Wrapped) -> Wrapped {
        get { self ?? value }
        set { self = value }
    }
}

struct TypePath {
    
    var type: Any.Type
    var key: CodingKey
}
