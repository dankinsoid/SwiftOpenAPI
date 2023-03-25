import Foundation

public struct ContentObject: Codable, Equatable, SpecificationExtendable, ExpressibleByDictionary {

	public typealias Key = MediaType
	public typealias Value = MediaTypeObject

	public var value: [Key: Value]
	//public var specificationExtensions: SpecificationExtensions? = nil

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

	public subscript(_ key: Key) -> Value? {
		get { value[key] }
		set { value[key] = newValue }
	}

	public init(from decoder: Decoder) throws {
		value = try decoder.decodeDictionary(of: [Key: Value].self)
	}

	public func encode(to encoder: Encoder) throws {
		try encoder.encodeDictionary(value)
	}
}
