import Foundation

/// A metadata object that allows for more fine-tuned XML model definitions.
///
/// When using arrays, XML element names are not inferred (for singular/plural forms) and the name property SHOULD be used to add that information. See examples for expected behavior.
public struct XMLObject: Codable, Equatable, SpecificationExtendable {

	/// Replaces the name of the element/attribute used for the described schema property. When defined within items, it will affect the name of the individual XML elements within the list. When defined alongside type being array (outside the items), it will affect the wrapping element and only if wrapped is true. If wrapped is false, it will be ignored.
	public var name: String?

	/// The URI of the namespace definition.
	public var namespace: URL?

	/// The prefix to be used for the name.
	public var prefix: String?

	/// Declares whether the property definition translates to an attribute instead of an element. Default value is false.
	/// wrapped    boolean    MAY be used only for an array definition. Signifies whether the array is wrapped (for example, <books><book/><book/></books>) or unwrapped (<book/><book/>). Default value is false. The definition takes effect only when defined alongside type being array (outside the items).
	public var attribute: Bool?

	public var specificationExtensions: SpecificationExtensions? = nil

	public init(name: String? = nil, namespace: URL? = nil, prefix: String? = nil, attribute: Bool? = nil) {
		self.name = name
		self.namespace = namespace
		self.prefix = prefix
		self.attribute = attribute
	}
}
