import Foundation

public protocol OpenAPIDescriptable {

	static var openAPIDescription: OpenAPIDescriptionType? { get }
}

public extension OpenAPIDescriptable {

	static var openAPIDescription: OpenAPIDescriptionType? {
		nil
	}
}

public protocol OpenAPIType: OpenAPIDescriptable {

	static var openAPISchema: SchemaObject { get }
}

extension String: OpenAPIType {

	public static var openAPISchema: SchemaObject { .string }
}

extension StaticString: OpenAPIType {

	public static var openAPISchema: SchemaObject { .string }
}

extension Int: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer(format: .int64) }
}

extension Int8: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer(format: .int32, range: range) }
}

extension Int16: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer(format: .int32, range: range) }
}

extension Int32: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer(format: .int32) }
}

extension Int64: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer(format: .int64) }
}

extension UInt: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer(format: .int64, range: 0...) }
}

extension UInt8: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer(format: .int32, range: range) }
}

extension UInt16: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer(format: .int32, range: range) }
}

extension UInt32: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer(format: .int32, range: 0...) }
}

extension UInt64: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer(format: .int64, range: 0...) }
}

extension Double: OpenAPIType {

	public static var openAPISchema: SchemaObject { .double }
}

extension Float: OpenAPIType {

	public static var openAPISchema: SchemaObject { .float }
}

extension Decimal: OpenAPIType {

	public static var openAPISchema: SchemaObject { .decimal }
}

extension Date: OpenAPIType {

	public static var openAPISchema: SchemaObject { .string(format: .dateTime) }
}

extension Data: OpenAPIType {

	public static var openAPISchema: SchemaObject { .string(format: .byte) }
}

extension UUID: OpenAPIType {

	public static var openAPISchema: SchemaObject { .string(format: .uuid) }
}

extension URL: OpenAPIType {

	public static var openAPISchema: SchemaObject { .string(format: .uri) }
}

extension Optional: OpenAPIDescriptable where Wrapped: OpenAPIDescriptable {

	public static var openAPIDescription: OpenAPIDescriptionType? {
		Wrapped.openAPIDescription
	}
}

extension Optional: OpenAPIType where Wrapped: OpenAPIType {

	public static var openAPISchema: SchemaObject { Wrapped.openAPISchema }
}

private extension FixedWidthInteger {

	static var range: AnyRange<Int> {
		Int(min) ... Int(max)
	}
}
