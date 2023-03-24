import Foundation

public struct RuntimeExpression: Codable, Hashable, ExpressibleByStringInterpolation, RawRepresentable, LosslessStringConvertible {
	public var rawValue: String

	public var surrounded: String {
		"{\(rawValue)}"
	}

	public var description: String { surrounded }

	public init(rawValue: String) {
		self.rawValue = rawValue.trimmingCharacters(in: ["{", "}"])
	}

	public init(stringLiteral value: String) {
		self.init(rawValue: value)
	}

	public init(stringInterpolation value: DefaultStringInterpolation) {
		self.init(rawValue: String(stringInterpolation: value))
	}

	public init(_ stringValue: String) {
		self.init(rawValue: stringValue)
	}

	public init(from decoder: Decoder) throws {
		try self.init(rawValue: String(from: decoder))
	}

	public func encode(to encoder: Encoder) throws {
		try rawValue.encode(to: encoder)
	}
}
