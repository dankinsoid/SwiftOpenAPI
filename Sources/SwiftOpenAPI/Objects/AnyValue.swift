import Foundation

@dynamicMemberLookup
public enum AnyValue: Codable, Equatable {
    
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
		case object([String: AnyValue])
    case array([AnyValue])
    
    public init(from decoder: Decoder) throws {
        do {
            self = try .string(String(from: decoder))
        } catch {
            do {
                self = try .bool(Bool(from: decoder))
            } catch {
                do {
                    self = try .int(Int(from: decoder))
                } catch {
                    do {
                        self = try .double(Double(from: decoder))
                    } catch {
                        do {
                            self = try .object([String: AnyValue](from: decoder))
                        } catch {
                            self = try .array([AnyValue](from: decoder))
                        }
                    }
                }
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .string(value): try value.encode(to: encoder)
        case let .bool(value): try value.encode(to: encoder)
        case let .int(value): try value.encode(to: encoder)
        case let .double(value): try value.encode(to: encoder)
        case let .object(value): try value.encode(to: encoder)
        case let .array(value): try value.encode(to: encoder)
        }
    }
    
    public subscript(_ key: String) -> AnyValue? {
        get {
            switch self {
            case let .object(value): return value[key]
            default: return nil
            }
        }
        set {
            switch self {
            case var .object(value):
                value[key] = newValue
                self = .object(value)
            default:
                break
            }
        }
    }
    
    public subscript(dynamicMember key: String) -> AnyValue? {
        get { self[key] }
        set { self[key] = newValue }
    }
    
    public subscript(_ index: Int) -> AnyValue? {
        switch self {
        case let .array(value):
            return value.indices.contains(index) ? value[index] : nil
        default:
            return nil
        }
    }
}

extension AnyValue: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, AnyValue)...) {
        self = .object(
            Dictionary(elements) { _, s in s }
        )
    }
}

extension AnyValue: ExpressibleByStringInterpolation {
    
    public init(stringLiteral value: String) {
        self = .string(value)
    }
    
    public init(stringInterpolation value: String.StringInterpolation) {
        self = .string(String(stringInterpolation: value))
    }
}

extension AnyValue: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: AnyValue...) {
        self = .array(elements)
    }
}

extension AnyValue: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension AnyValue: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension AnyValue: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension AnyValue {
    
    public static func encode(_ value: some Encodable) -> AnyValue {
        let encoder = AnyValueEncoder()
        try? value.encode(to: encoder)
        return encoder.result
    }
}

private final class AnyValueEncoder: Encoder {
    
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    var result: AnyValue
    
    init(codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
        self.userInfo = [:]
        self.result = .object([:])
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = AnyValueKeyedEncodingContainer<Key>(
            codingPath: codingPath,
            result: Ref { [self] in
                guard case let .object(value) = result else { return [:] }
                return value
            } set: { [self] newValue in
                result = .object(newValue)
            }
        )
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        AnyValueUnkeyedEncodingContainer(
            codingPath: codingPath,
            result: Ref { [self] in
                if case let .array(value) = result {
                		return value
                }
                return []
            } set: { [self] newValue in
                result = .array(newValue)
            }
        )
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        AnyValueSingleValueEncodingContainer(
            codingPath: codingPath,
            result: Ref { [self] in
                result
            } set: { [self] newValue in
                result = newValue
            }
        )
    }
}

private struct AnyValueSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    var codingPath: [CodingKey]
    @Ref var result: AnyValue
    
    mutating func encodeNil() throws {
    }
    
    mutating func encode(_ value: Bool) throws {
        result = .bool(value)
    }
    
    mutating func encode(_ value: String) throws {
        result = .string(value)
    }
    
    mutating func encode(_ value: Double) throws {
        result = .double(value)
    }
    
    mutating func encode(_ value: Float) throws {
        result = .double(Double(value))
    }
    
    mutating func encode(_ value: Int) throws {
        result = .int(value)
    }
    
    mutating func encode(_ value: Int8) throws {
        result = .int(Int(value))
    }
    
    mutating func encode(_ value: Int16) throws {
        result = .int(Int(value))
    }
    
    mutating func encode(_ value: Int32) throws {
        result = .int(Int(value))
    }
    
    mutating func encode(_ value: Int64) throws {
        result = .int(Int(value))
    }
    
    mutating func encode(_ value: UInt) throws {
        result = .int(Int(value))
    }
    
    mutating func encode(_ value: UInt8) throws {
        result = .int(Int(value))
    }
    
    mutating func encode(_ value: UInt16) throws {
        result = .int(Int(value))
    }
    
    mutating func encode(_ value: UInt32) throws {
        result = .int(Int(value))
    }
    
    mutating func encode(_ value: UInt64) throws {
        result = .int(Int(value))
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let encoder = AnyValueEncoder(codingPath: codingPath)
        try value.encode(to: encoder)
        result = encoder.result
    }
}

private struct AnyValueKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    
    var codingPath: [CodingKey]
    @Ref var result: [String: AnyValue]
    
    @inline(__always)
    private func str(_ key: Key) -> String {
        key.stringValue
    }
    
    mutating func encodeNil(forKey key: Key) throws {
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        result[str(key)] = .bool(value)
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        result[str(key)] = .string(value)
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        result[str(key)] = .double(value)
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        result[str(key)] = .double(Double(value))
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        result[str(key)] = .int(value)
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        result[str(key)] = .int(Int(value))
    }
    
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let encoder = AnyValueEncoder(codingPath: nestedPath(for: key))
        try value.encode(to: encoder)
        result[str(key)] = encoder.result
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let strKey = str(key)
        let container = AnyValueKeyedEncodingContainer<NestedKey>(
            codingPath: nestedPath(for: key),
            result: Ref { [$result] in
                guard
                    case let .object(value) = $result.wrappedValue[strKey]
                else { return [:] }
                return value
            } set: { [$result] newValue in
                $result.wrappedValue[strKey] = .object(newValue)
            }
        )
        result[strKey] = .object([:])
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let strKey = str(key)
        let container = AnyValueUnkeyedEncodingContainer(
            codingPath: nestedPath(for: key),
            result: Ref { [$result] in
                guard
                    case let .array(value) = $result.wrappedValue[strKey]
                else { return [] }
                return value
            } set: { [$result] newValue in
                $result.wrappedValue[strKey] = .array(newValue)
            }
        )
        result[strKey] = .array([])
        return container
    }
    
    mutating func superEncoder() -> Encoder {
        AnyValueEncoder(codingPath: codingPath)
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        result[str(key)] = .object([:])
        return AnyValueEncoder(codingPath: nestedPath(for: key))
    }
    
    private func nestedPath(for key: Key) -> [CodingKey] {
        codingPath + [key]
    }
}

private struct AnyValueUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    var codingPath: [CodingKey]
    var count: Int { result.count }
    @Ref var result: [AnyValue]
    
    private var nestedPath: [CodingKey] {
        codingPath + [Key(intValue: codingPath.count)]
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let index = result.count
        let container = AnyValueKeyedEncodingContainer<NestedKey>(
            codingPath: nestedPath,
            result: Ref { [$result] in
                guard
                    $result.wrappedValue.indices.contains(index),
                    case let .object(value) = $result.wrappedValue[index]
                else { return [:] }
                return value
            } set: { [$result] newValue in
                guard $result.wrappedValue.indices.contains(index) else {
                    return
                }
                $result.wrappedValue[index] = .object(newValue)
            }
        )
        result.append(.object([:]))
        return KeyedEncodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let index = result.count
        let container = AnyValueUnkeyedEncodingContainer(
            codingPath: nestedPath,
            result: Ref { [$result] in
                guard
                    $result.wrappedValue.indices.contains(index),
                    case let .array(value) = $result.wrappedValue[index]
                else { return [] }
                return value
            } set: { [$result] newValue in
                guard $result.wrappedValue.indices.contains(index) else {
                    return
                }
                $result.wrappedValue[index] = .array(newValue)
            }
        )
        result.append(.array([]))
        return container
    }
    
    mutating func encodeNil() throws {
    }
    
    mutating func superEncoder() -> Encoder {
        AnyValueEncoder(codingPath: codingPath)
    }
    
    mutating func encode(_ value: Bool) throws {
        result.append(.bool(value))
    }
    
    mutating func encode(_ value: String) throws {
        result.append(.string(value))
    }
    
    mutating func encode(_ value: Double) throws {
        result.append(.double(value))
    }
    
    mutating func encode(_ value: Float) throws {
        result.append(.double(Double(value)))
    }
    
    mutating func encode(_ value: Int) throws {
        result.append(.int(value))
    }
    
    mutating func encode(_ value: Int8) throws {
        result.append(.int(Int(value)))
    }
    
    mutating func encode(_ value: Int16) throws {
        result.append(.int(Int(value)))
    }
    
    mutating func encode(_ value: Int32) throws {
        result.append(.int(Int(value)))
    }
    
    mutating func encode(_ value: Int64) throws {
        result.append(.int(Int(value)))
    }
    
    mutating func encode(_ value: UInt) throws {
        result.append(.int(Int(value)))
    }
    
    mutating func encode(_ value: UInt8) throws {
        result.append(.int(Int(value)))
    }
    
    mutating func encode(_ value: UInt16) throws {
        result.append(.int(Int(value)))
    }
    
    mutating func encode(_ value: UInt32) throws {
        result.append(.int(Int(value)))
    }
    
    mutating func encode(_ value: UInt64) throws {
        result.append(.int(Int(value)))
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let encoder = AnyValueEncoder(codingPath: nestedPath)
        try value.encode(to: encoder)
        result.append(encoder.result)
    }
    
    private struct Key: CodingKey {
        
        var stringValue: String {
            "\(intValue ?? 0)"
        }
        var intValue: Int?
        
        init(intValue: Int) {
            self.intValue = intValue
        }
        
        init?(stringValue: String) {
            return nil
        }
    }
}

@propertyWrapper
private struct Ref<Value> {
    
    let get: () -> Value
    let set: (Value) -> Void
    
    var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
    
    var projectedValue: Ref {
        get { self }
        set { self = newValue }
    }
}
