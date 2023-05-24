import Foundation

public struct RuntimeExpression: Codable, Hashable, ExpressibleByStringInterpolation, RawRepresentable, LosslessStringConvertible {

	public var rawValue: String

	public var surrounded: String {
		"{\(rawValue)}"
	}

	public var description: String { surrounded }

	public init?(rawValue: String) {
		self.init(rawValue)
	}

	public init(stringLiteral value: String) {
		rawValue = value.trimmingCharacters(in: ["{", "}"])
	}

	public init(stringInterpolation value: DefaultStringInterpolation) {
		self.init(stringLiteral: String(stringInterpolation: value))
	}

	public init?(_ stringValue: String) {
		guard stringValue.hasPrefix("{"), stringValue.hasSuffix("}") else {
			return nil
		}
		self.init(stringLiteral: stringValue)
	}

	public init(from decoder: Decoder) throws {
		try self.init(stringLiteral: String(from: decoder))
	}

	public func encode(to encoder: Encoder) throws {
		try rawValue.encode(to: encoder)
	}
}
