import Foundation

public protocol OpenAPIType: OpenAPIDescriptable {

	static var openAPISchema: SchemaObject { get }
}

extension String: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.string) }
}

extension StaticString: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.string) }
}

extension Int: OpenAPIType {

	public static var openAPISchema: SchemaObject { .integer }
}

extension Int8: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.integer, format: .int32) }
}

extension Int16: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.integer, format: .int32) }
}

extension Int32: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.integer, format: .int32) }
}

extension Int64: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.integer, format: .int32) }
}

extension UInt: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.integer, format: .int32) }
}

extension UInt8: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.integer, format: .int32) }
}

extension UInt16: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.integer, format: .int32) }
}

extension UInt32: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.integer, format: .int32) }
}

extension UInt64: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.integer, format: .int32) }
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

	public static var openAPISchema: SchemaObject { .primitive(.string, format: .dateTime) }
}

extension Data: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.string, format: .byte) }
}

extension UUID: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.string, format: .uuid) }
}

extension URL: OpenAPIType {

	public static var openAPISchema: SchemaObject { .primitive(.string, format: .uri) }
}

extension Optional: OpenAPIDescriptable where Wrapped: OpenAPIDescriptable {

	public static var openAPIDescription: OpenAPIDescriptionType? {
		Wrapped.openAPIDescription
	}
}

extension Optional: OpenAPIType where Wrapped: OpenAPIType {

	public static var openAPISchema: SchemaObject { Wrapped.openAPISchema }
}
