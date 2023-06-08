import Foundation

@dynamicMemberLookup
public enum AnyValue: Codable, Equatable {

	case string(String)
	case bool(Bool)
	case int(Int)
	case double(Double)
	case object([String: AnyValue])
	case array([AnyValue])
	case null

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
							do {
								self = try .array([AnyValue](from: decoder))
							} catch {
								let container = try decoder.singleValueContainer()
								if container.decodeNil() {
									self = .null
								} else {
									throw DecodingError.dataCorrupted(
										DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown type")
									)
								}
							}
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
		case .null:
			var container = encoder.singleValueContainer()
			try container.encodeNil()
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

	public var dataType: DataType {
		switch self {
		case .string: return .string
		case .bool: return .boolean
		case .int: return .integer
		case .double: return .number
		case .object: return .object
		case .array: return .array
		case .null: return .null
		}
	}
}

extension AnyValue: ExpressibleByDictionary {

	public typealias Key = String
	public typealias Value = AnyValue

	public init(dictionaryElements elements: [(String, AnyValue)]) {
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

extension AnyValue: ExpressibleByArray {

	public typealias ArrayLiteralElement = AnyValue

	public init(arrayElements array: [AnyValue]) {
		self = .array(array)
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

extension AnyValue: ExpressibleByNilLiteral {
	
	public init(nilLiteral: ()) {
		self = .null
	}
}

extension AnyValue: LosslessStringConvertible {
	
	public var description: String {
		switch self {
		case .string(let string):
			return string.description
		case .bool(let bool):
			return bool.description
		case .int(let int):
			return int.description
		case .double(let double):
			return double.description
		case .object(let dictionary):
			return dictionary.description
		case .array(let array):
			return array.description
		case .null:
			return "nil"
		}
	}
	
	public init(_ description: String) {
		switch description {
		case "nil":
			self = .null
		default:
			if let int = Int(description) {
				self = .int(int)
			} else if let bool = Bool(description) {
				self = .bool(bool)
			} else if let double = Double(description) {
				self = .double(double)
			} else {
				self = .string(description)
			}
		}
	}
}

public extension AnyValue {

	static func encode(_ value: Encodable, dateFormat: DateEncodingFormat = .default) throws -> AnyValue {
		let encoder = AnyValueEncoder(dateFormat: dateFormat)
		return try encoder.encode(value)
	}
}
