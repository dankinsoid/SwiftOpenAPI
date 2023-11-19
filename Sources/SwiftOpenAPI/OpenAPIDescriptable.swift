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
/// - Note: Your type must have a `CodingKeys` enum (which is synthesized implicitly for `Encodable` and `Decodable` types).
/// Otherwise, if you use a custom `Codable` implementation or if the type is not `Codable` at all, use `OpenAPIRawAutoDescriptable`.
///
/// Example:
/// ```swift
/// /// Description of MyType.
/// @OpenAPIAutoDescriptable
/// struct MyType: Codable {
///
///     /// Description of myProperty.
///     var myProperty: String
/// }
/// ```
///
/// The `OpenAPIAutoDescriptable` significantly reduces the need for boilerplate code in
/// API documentation, streamlining the process of maintaining up-to-date and accurate OpenAPI docs.
@attached(member, conformances: OpenAPIDescriptable, names: arbitrary)
@attached(extension, conformances: OpenAPIDescriptable, names: arbitrary)
public macro OpenAPIAutoDescriptable() = #externalMacro(
    module: "SwiftOpenAPIMacros",
    type: "OpenAPICodingKeyDescriptionMacro"
)

/// `OpenAPIRawAutoDescriptable`: An automatic implementation macro for the `OpenAPIDescriptable` protocol.
///
/// This macro facilitates the automatic implementation of the `OpenAPIRawAutoDescriptable` protocol
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
/// - Note: If your type has a `CodingKeys` enum, it is better to use the `OpenAPIAutoDescriptable` macro.
///
/// Example:
/// ```swift
/// /// Description of MyType.
/// @OpenAPIRawAutoDescriptable
/// struct MyType {
///
///     /// Description of myProperty.
///     var myProperty: String
/// }
/// ```
///
/// The `OpenAPIRawAutoDescriptable` significantly reduces the need for boilerplate code in
/// API documentation, streamlining the process of maintaining up-to-date and accurate OpenAPI docs.
@attached(member, conformances: OpenAPIDescriptable, names: arbitrary)
@attached(extension, conformances: OpenAPIDescriptable, names: arbitrary)
public macro OpenAPIRawAutoDescriptable() = #externalMacro(
    module: "SwiftOpenAPIMacros",
    type: "OpenAPIStringDescriptionMacro"
)
