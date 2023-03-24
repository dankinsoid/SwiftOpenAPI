import Foundation

/// A simple object to allow referencing other components in the OpenAPI document, internally and externally.
///
/// The $ref string value contains a URI RFC3986, which identifies the location of the value being referenced.
///
/// See the rules for resolving Relative References.
public struct ReferenceObject: Codable, Equatable {
	/// The reference identifier. This MUST be in the form of a URI.
	public var ref: String

	/// A short summary which by default SHOULD override that of the referenced component. If the referenced object-type does not allow a summary field, then this field has no effect.
	public var summary: String?

	/// A description which by default SHOULD override that of the referenced component. CommonMark syntax MAY be used for rich text representation. If the referenced object-type does not allow a description field, then this field has no effect.
	public var description: String?

	public enum CodingKeys: String, CodingKey {
		case ref = "$ref"
		case summary
		case description
	}

	public init(ref: String, summary: String? = nil, description: String? = nil) {
		self.ref = ref
		self.summary = summary
		self.description = description
	}
}

extension ReferenceObject: ExpressibleByStringInterpolation {
	public init(stringLiteral value: String) {
		self.init(ref: value)
	}

	public init(stringInterpolation value: DefaultStringInterpolation) {
		self.init(ref: String(stringInterpolation: value))
	}
}

public protocol ReferenceObjectExpressible {
	init(referenceObject: ReferenceObject)
}

extension ReferenceOr: ReferenceObjectExpressible {
	public init(referenceObject: ReferenceObject) {
		self = .ref(referenceObject)
	}
}

extension ReferenceObject: ReferenceObjectExpressible {
	public init(referenceObject: ReferenceObject) {
		self = referenceObject
	}
}

public extension ReferenceObjectExpressible {
	/// file#/type
	static func ref(to type: String, file: String? = nil) -> Self {
		Self(
			referenceObject: ReferenceObject(
				ref: "\(file ?? "")#/\(type)"
			)
		)
	}

	/// file#/type
	static func ref(to type: (some Any).Type, file: String? = nil) -> Self {
		.ref(to: .typeName(type), file: file)
	}

	/// #/components/path/type
	static func ref(components path: String, _ name: String) -> Self {
		Self(referenceObject: "#/components/\(path)/\(name)")
	}

	/// #/components/path/type
	static func ref(components path: String, _ type: Any.Type) -> Self {
		.ref(components: path, .typeName(type))
	}
}
