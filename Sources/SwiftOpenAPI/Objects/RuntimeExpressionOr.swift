import Foundation

public enum RuntimeExpressionOr<Value: Codable & Equatable>: Codable, Equatable {
    
    case expression(RuntimeExpression)
    case value(Value)
    
    public init(from decoder: Decoder) throws {
        do {
            let string = try String(from: decoder)
            guard string.hasPrefix("{"), string.hasSuffix("}") else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Invalid expression string \(string)"
                    )
                )
            }
            self = .expression(RuntimeExpression(rawValue: string))
        } catch {
            self = try .expression(RuntimeExpression(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .expression(let runtimeExpression):
            try runtimeExpression.encode(to: encoder)
        case .value(let value):
            try value.encode(to: encoder)
        }
    }
}
