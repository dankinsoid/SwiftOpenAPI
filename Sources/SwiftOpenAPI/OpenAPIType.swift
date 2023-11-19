import Foundation

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

	public static var openAPISchema: SchemaObject { Wrapped.openAPISchema.with(\.nullable, true) }
}

extension Dictionary: OpenAPIDescriptable where Key == String, Value: OpenAPIType {}

extension Dictionary: OpenAPIType where Key == String, Value: OpenAPIType {

	public static var openAPISchema: SchemaObject {
		.dictionary(of: .value(Value.openAPISchema))
	}
}

extension Array: OpenAPIDescriptable where Element: OpenAPIDescriptable {}

extension Array: OpenAPIType where Element: OpenAPIType {

	public static var openAPISchema: SchemaObject {
		.array(of: .value(Element.openAPISchema))
	}
}

extension Set: OpenAPIDescriptable where Element: OpenAPIDescriptable {}

extension Set: OpenAPIType where Element: OpenAPIType {

	public static var openAPISchema: SchemaObject {
		.array(of: .value(Element.openAPISchema), uniqueItems: true)
	}
}

private extension FixedWidthInteger {

	static var range: AnyRange<Int> {
		Int(min) ... Int(max)
	}
}
