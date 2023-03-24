import Foundation

/// Lists the required security schemas to execute this operation. The name used for each property MUST correspond to a security scheme declared in the Security Schemes under the Components Object.
///
/// Security Requirement Objects that contain multiple schemas require that all schemas MUST be satisfied for a request to be authorized.
/// This enables support for scenarios where multiple query parameters or HTTP headers are required to convey security information.
///
/// When a list of Security Requirement Objects is defined on the OpenAPI Object or Operation Object, only one of the Security Requirement Objects in the list needs to be satisfied to authorize the request.
public struct SecurityRequirementObject: Codable, Equatable, SpecificationExtendable {
	/// Each name MUST correspond to a security scheme which is declared in the Security Schemes under the ```ComponentsObject```. If the security scheme is of type "oauth2" or "openIdConnect", then the value is a list of scope names required for the execution, and the list MAY be empty if authorization does not require a specified scope. For other security scheme types, the array MAY contain a list of role names which are required for the execution, but are not otherwise defined or exchanged in-band.
	public var name: String
	public var values: [String]
	public var specificationExtensions: SpecificationExtensions? = nil

	public init(from decoder: Decoder) throws {
		let dictionary = try [String: [String]](from: decoder)
		guard dictionary.count == 1 else {
			throw DecodingError.dataCorrupted(
				DecodingError.Context(
					codingPath: decoder.codingPath,
					debugDescription: "Invalid SecurityRequirementObject \(dictionary)"
				)
			)
		}
		self.init(dictionary[dictionary.startIndex].key, dictionary[dictionary.startIndex].value)
		specificationExtensions = try SpecificationExtensions(from: decoder)
	}

	public init(
		_ name: String,
		_ values: [String]
	) {
		self.name = name
		self.values = values
	}

	public func encode(to encoder: Encoder) throws {
		try [name: values].encode(to: encoder)
		try specificationExtensions.encode(to: encoder)
	}
}
