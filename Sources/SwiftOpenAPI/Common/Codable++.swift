import Foundation

extension Decoder {
	
	func decodeDictionary<Key: LosslessStringConvertible, Value: Decodable>(of type: [Key: Value].Type) throws -> [Key: Value] {
		let container = try container(keyedBy: StringKey<Key>.self)
		let pairs = try container.allKeys.filter { !$0.stringValue.hasPrefix("x-") }.compactMap {
			try ($0.value, container.decode(Value.self, forKey: $0))
		}
		return Dictionary(pairs) { _, second in
			second
		}
	}
}

extension Encoder {
	
	func encodeDictionary<Key: LosslessStringConvertible>(_ dict: [Key: some Encodable]) throws {
		var container = container(keyedBy: StringKey<Key>.self)
		for (key, value) in dict {
			try container.encode(value, forKey: StringKey(key))
		}
	}
}
