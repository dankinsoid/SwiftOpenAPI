import Foundation

public struct ResponsesObject: Codable, Equatable, SpecificationExtendable, ExpressibleByDictionary {
	public typealias Value = ReferenceOr<ResponseObject>

	public var value: [Key: Value]
	public var specificationExtensions: SpecificationExtensions? = nil

	public init(_ value: [Key: Value] = [:]) {
		self.value = value
	}

	public init(dictionaryElements elements: [(Key, Value)]) {
		self.init(
			Dictionary(elements) { _, second in
				second
			}
		)
	}

	public init(from decoder: Decoder) throws {
		(value, specificationExtensions) = try decoder.decodeDictionary(of: [Key: Value].self)
	}

	public func encode(to encoder: Encoder) throws {
		try encoder.encodeDictionary(value, specs: specificationExtensions)
	}

	public subscript(_ key: Key) -> Value? {
		get { value[key] }
		set { value[key] = newValue }
	}
}

public extension ResponsesObject {
	enum Key: Hashable, Codable, Equatable, RawRepresentable, CodingKey, ExpressibleByIntegerLiteral, LosslessStringConvertible {
		case code(Int)
		case `default`

		public var rawValue: String {
			switch self {
			case let .code(int):
				return "\(int)"
			case .default:
				return Self.defaultRawValue
			}
		}

		public var stringValue: String { rawValue }
		public var description: String { rawValue }

		public var intValue: Int? {
			if case let .code(int) = self {
				return int
			}
			return nil
		}

		public init?(rawValue: String) {
			if rawValue == Self.defaultRawValue {
				self = .default
			} else if let code = Int(rawValue) {
				self = .code(code)
			} else {
				return nil
			}
		}

		public init?(intValue: Int) {
			self = .code(intValue)
		}

		public init(integerLiteral value: Int) {
			self = .code(value)
		}

		public init?(stringValue: String) {
			self.init(rawValue: stringValue)
		}

		public init?(_ description: String) {
			self.init(rawValue: description)
		}

		public init(from decoder: Decoder) throws {
			let rawValue = try String(from: decoder)
			guard let key = Self(rawValue: rawValue) else {
				throw DecodingError.dataCorrupted(
					DecodingError.Context(
						codingPath: decoder.codingPath,
						debugDescription: "Invalid responses field, expected 'default' or status code, \(rawValue) found"
					)
				)
			}
			self = key
		}

		public func encode(to encoder: Encoder) throws {
			try rawValue.encode(to: encoder)
		}

		private static let defaultRawValue = "default"
	}
}
