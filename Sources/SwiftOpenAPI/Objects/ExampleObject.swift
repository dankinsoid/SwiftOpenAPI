import Foundation

public struct ExampleObject: Codable, Equatable, SpecificationExtendable {

	/// Short description for the example.
	public var summary: String?

	/// Long description for the example. CommonMark syntax MAY be used for rich text representation.
	public var description: String?

	/// Embedded literal example. The value field and externalValue field are mutually exclusive. To represent examples of media types that cannot naturally represented in JSON or YAML, use a string value to contain the example, escaping where necessary.
	public var value: AnyValue?

	/// A URI that points to the literal example. This provides the capability to reference examples that cannot easily be included in JSON or YAML documents. The value field and externalValue field are mutually exclusive. See the rules for resolving Relative References.
	public var externalValue: String?

	public var specificationExtensions: SpecificationExtensions? = nil

	public init(summary: String? = nil, description: String? = nil, value: AnyValue? = nil, externalValue: String? = nil) {
		self.summary = summary
		self.description = description
		self.value = value
		self.externalValue = externalValue
	}
}

extension ExampleObject: ExpressibleByDictionary {
	
	public typealias Key = String
	public typealias Value = AnyValue
	
	public subscript(_ key: String) -> AnyValue? {
		get {
			value?[key]
		}
		set {
			value?[key] = newValue
		}
	}
	
	public init(dictionaryElements elements: [(String, AnyValue)]) {
		self.init(value: .object(Dictionary(elements) { _, s in s }))
	}
}
