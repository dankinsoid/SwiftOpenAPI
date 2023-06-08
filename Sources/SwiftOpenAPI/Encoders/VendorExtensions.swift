import Foundation
import OpenAPIKit

extension KeyEncodingStrategy {
	
	static var vendorExtensions: KeyEncodingStrategy {
		.custom { last in
			var string = last.toSnakeCase(separator: "-").replacingOccurrences(of: "_", with: "-")
			if !string.hasPrefix("x-") {
				string = "x-\(string)"
			}
			return string
		}
	}
}

public extension JSONDecoder.KeyDecodingStrategy {
	
	static var vendorExtensions: JSONDecoder.KeyDecodingStrategy {
		.custom { codingPath in
			guard let last = codingPath.last else {
				return StringKey<String>("")
			}
			var string = last.stringValue
			if string.hasPrefix("x-") {
				string.removeFirst(2)
			}
			string = string.replacingOccurrences(of: "_", with: "-").toCamelCase(separator: "-")
			return StringKey(string)
		}
	}
}

public extension JSONEncoder.KeyEncodingStrategy {
	
	static var vendorExtensions: JSONEncoder.KeyEncodingStrategy {
		.vendorExtensions(nested: .useDefaultKeys)
	}
	
	static func vendorExtensions(nested: KeyEncodingStrategy) -> JSONEncoder.KeyEncodingStrategy {
		.custom { codingPath in
			guard let last = codingPath.last else {
				return StringKey<String>("")
			}
			let strategy = codingPath.count > 1 ? nested : KeyEncodingStrategy.vendorExtensions
			return StringKey(strategy.encode(last.stringValue))
		}
	}
}

public extension [String: AnyCodable] {
	
	static func vendorExtensions(
		_ value: some Encodable,
		encoder: JSONEncoder = JSONEncoder(),
		decoder: JSONDecoder = JSONDecoder(),
		nestedKeyStrategy: KeyEncodingStrategy = .convertToSnakeCase
	) throws -> [String: AnyCodable] {
		encoder.keyEncodingStrategy = .vendorExtensions(nested: nestedKeyStrategy)
		decoder.keyDecodingStrategy = .useDefaultKeys
		let data = try encoder.encode(value)
		return try decoder.decode([String: AnyCodable].self, from: data)
	}
}
