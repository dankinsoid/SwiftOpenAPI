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
/// - Parameters:
///   - codingKeys: The Bool value indicating whether to use a `CodingKeys` enum for properties names.
///   When `true`, the property names are extracted from the `CodingKeys` enum, only stored properties are collected.
///   When `false`, the property names are used directly, all properties are collected including computed, lazy and with attributes.
///   Defaults to `true`.
///   - docCommentsOnly: The Bool value indicating whether to use only documentation comments (`///` and `/**`). Defaults to `false`.
///   - includeAttributes: The Bool value indicating whether to include properties with attributes. Defaults to `false`. The property is ignored when `codingKeys` is `false`.
///
/// Features:
/// - Automatically extracts and synthesizes descriptions from comments on types and stored properties.
/// - Simplifies the process of conforming to `OpenAPIDescriptable` by generating necessary implementation details.
///
/// - Warning: By default this macro does not process properties with attributes, as it's currently not feasible
///   to distinguish between stored and computed properties in such cases.
///   You can override this behavior by setting the `includeAttributes` parameter to `true` or `codingKeys` to `false`.
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
public macro OpenAPIAutoDescriptable(
    codingKeys: Bool = true,
    docCommentsOnly: Bool = false,
    includeAttributes: Bool = false
) = #externalMacro(
    module: "SwiftOpenAPIMacros",
    type: "OpenAPIDescriptionMacro"
)
