import Foundation
@_exported import OpenAPIKit

public protocol OpenAPIDescriptable {

	static var openAPIDescription: OpenAPIDescriptionType? { get }
}

public extension OpenAPIDescriptable {

	static var openAPIDescription: OpenAPIDescriptionType? {
		nil
	}
}

public protocol OpenAPIType: OpenAPIDescriptable {

	static var openAPISchema: JSONSchema { get }
}

extension String: OpenAPIType {

	public static var openAPISchema: JSONSchema { .string }
}

extension StaticString: OpenAPIType {

	public static var openAPISchema: JSONSchema { .string }
}

extension Int: OpenAPIType {

	public static var openAPISchema: JSONSchema { .integer }
}

extension Int8: OpenAPIType {

	public static var openAPISchema: JSONSchema {
		.integer(format: .int32, maximum: (Int(Self.max), false), minimum: (Int(Self.min), false))
	}
}

extension Int16: OpenAPIType {

	public static var openAPISchema: JSONSchema {
		.integer(format: .int32, maximum: (Int(Self.max), false), minimum: (Int(Self.min), false))
	}
}

extension Int32: OpenAPIType {

	public static var openAPISchema: JSONSchema { .integer(format: .int32) }
}

extension Int64: OpenAPIType {

	public static var openAPISchema: JSONSchema { .integer(format: .int64) }
}

extension UInt: OpenAPIType {

	public static var openAPISchema: JSONSchema { .integer(format: .int64, minimum: (0, false)) }
}

extension UInt8: OpenAPIType {

	public static var openAPISchema: JSONSchema {
		.integer(format: .int32, maximum: (Int(Self.max), false), minimum: (Int(Self.min), false))
	}
}

extension UInt16: OpenAPIType {

	public static var openAPISchema: JSONSchema {
		.integer(format: .int32, maximum: (Int(Self.max), false), minimum: (Int(Self.min), false))
	}
}

extension UInt32: OpenAPIType {

	public static var openAPISchema: JSONSchema { .integer(format: .int32, minimum: (0, false)) }
}

extension UInt64: OpenAPIType {

	public static var openAPISchema: JSONSchema { .integer(format: .int64, minimum: (0, false)) }
}

extension Double: OpenAPIType {

	public static var openAPISchema: JSONSchema { .number(format: .double) }
}

extension Float: OpenAPIType {

	public static var openAPISchema: JSONSchema { .number(format: .float) }
}

extension Decimal: OpenAPIType {

	public static var openAPISchema: JSONSchema { .number(format: .other("decimal")) }
}

extension Date: OpenAPIType {

	public static var openAPISchema: JSONSchema { .string(format: .dateTime) }
}

extension Data: OpenAPIType {

	public static var openAPISchema: JSONSchema { .string(format: .byte) }
}

extension UUID: OpenAPIType {

	public static var openAPISchema: JSONSchema { .string(format: .other("uuid")) }
}

extension URL: OpenAPIType {

	public static var openAPISchema: JSONSchema { .string(format: .other("uri")) }
}

extension Optional: OpenAPIDescriptable where Wrapped: OpenAPIDescriptable {

	public static var openAPIDescription: OpenAPIDescriptionType? {
		Wrapped.openAPIDescription
	}
}

extension Optional: OpenAPIType where Wrapped: OpenAPIType {

	public static var openAPISchema: JSONSchema { Wrapped.openAPISchema }
}
