import Foundation
import SwiftOpenAPIMacros

public protocol OpenAPIDescriptable {

	static var openAPIDescription: OpenAPIDescriptionType? { get }
}

public extension OpenAPIDescriptable {

	static var openAPIDescription: OpenAPIDescriptionType? {
		nil
	}
}

/// `OpenAPIAutoDescriptable`: An automatic implementation macro for the `OpenAPIDescriptable` protocol.
///
/// This macro facilitates the automatic implementation of the `OpenAPIDescriptable` protocol
/// for any Swift type, utilizing both standard comments (`//`) and documentation comments (`///`)
/// for the type and its stored properties. It's particularly useful for generating comprehensive
/// OpenAPI documentation directly from your source code.
///
/// Usage:
/// - Apply this macro to any type that requires documentation in the generated OpenAPI documentation.
/// - Ensure each type and its stored properties are well-documented with relevant comments.
///
/// Features:
/// - Automatically extracts and synthesizes descriptions from comments on types and stored properties.
/// - Simplifies the process of conforming to `OpenAPIDescriptable` by generating necessary implementation details.
///
/// - Warning: This macro does not process properties with attributes, as it's currently not feasible
///   to distinguish between stored and computed properties in such cases.
///
/// - Note: The accuracy of the OpenAPI descriptions generated relies heavily on the quality and
///   comprehensiveness of the comments in your code.
///
/// Example:
/// ```swift
/// /// Description of MyType.
/// @OpenAPIAutoDescriptable
/// struct MyType: OpenAPIDescriptable {
///
///     /// Description of myProperty.
///     var myProperty: String
/// }
/// ```
///
/// The `OpenAPIAutoDescriptable` significantly reduces the need for boilerplate code in
/// API documentation, streamlining the process of maintaining up-to-date and accurate OpenAPI docs.
@attached(extension, conformances: OpenAPIDescriptable, names: arbitrary)
public macro OpenAPIAutoDescriptable() = #externalMacro(
    module: "SwiftOpenAPIMacros",
    type: "OpenAPIDescriptionMacro"
)

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
