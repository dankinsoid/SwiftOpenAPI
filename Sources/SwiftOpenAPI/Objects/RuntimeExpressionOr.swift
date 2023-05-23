import Foundation

public enum RuntimeExpressionOr<Value: Codable & Equatable>: Codable, Equatable {

	case expression(RuntimeExpression)
	case value(Value)

	public init(from decoder: Decoder) throws {
		do {
			let string = try String(from: decoder)
			guard let expression = RuntimeExpression(string) else {
				throw DecodingError.dataCorrupted(
					DecodingError.Context(
						codingPath: decoder.codingPath,
						debugDescription: "Invalid expression string \(string)"
					)
				)
			}
			self = .expression(expression)
		} catch {
			self = try .value(Value(from: decoder))
		}
	}

	public func encode(to encoder: Encoder) throws {
		switch self {
		case let .expression(runtimeExpression):
			try runtimeExpression.encode(to: encoder)
		case let .value(value):
			try value.encode(to: encoder)
		}
	}
}
