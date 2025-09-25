import Foundation

public struct KeyEncodingStrategy {

	public let encode: (String) -> String
}

public extension KeyEncodingStrategy {

    static var `default`: KeyEncodingStrategy {
        get {
            defaultKeyEncodingStrategy.wrappedValue
        }
        set {
            defaultKeyEncodingStrategy.wrappedValue = newValue
        }
    }

	static var useDefaultKeys: KeyEncodingStrategy = .custom { $0 }

	static func custom(_ encode: @escaping (String) -> String) -> KeyEncodingStrategy {
		KeyEncodingStrategy(encode: encode)
	}

	static var convertToSnakeCase: KeyEncodingStrategy {
		.convertToSnakeCase(separator: "_")
	}

	static func convertToSnakeCase(separator: String) -> KeyEncodingStrategy {
		.custom {
			$0.toSnakeCase(separator: separator)
		}
	}
}

private let defaultKeyEncodingStrategy = Lock(KeyEncodingStrategy.useDefaultKeys)
