import Foundation

public struct HeaderObject: Codable, Equatable, SpecificationExtendable {

	/// A brief description of the parameter. This could contain examples of use. CommonMark syntax MAY be used for rich text representation.
	public var description: String?

	/// Determines whether this parameter is mandatory. If the parameter location is "path", this property is REQUIRED and its value MUST be true. Otherwise, the property MAY be included and its default value is false.
	public var required: Bool?

	/// Specifies that a parameter is deprecated and SHOULD be transitioned out of usage. Default value is false.
	public var deprecated: Bool?

	/// Sets the ability to pass empty-valued parameters. This is valid only for query parameters and allows sending a parameter with an empty value. Default value is false. If style is used, and if behavior is n/a (cannot be serialized), the value of allowEmptyValue SHALL be ignored. Use of this property is NOT RECOMMENDED, as it is likely to be removed in a later revision.
	public var allowEmptyValue: Bool?

	/// Describes how the parameter value will be serialized depending on the type of the parameter value. Default values (based on value of in): for query - form; for path - simple; for header - simple; for cookie - form.
	public var style: ParameterObject.Style?

	///  When this is true, parameter values of type array or object generate separate parameters for each value of the array or key-value pair of the map. For other types of parameters this property has no effect. When style is form, the default value is true. For all other styles, the default value is false.
	public var explode: Bool?

	/// Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986 :/?#[]@!$&'()*+,;= to be included without percent-encoding. This property only applies to parameters with an in value of query. The default value is false.
	public var allowReserved: Bool?

	/// The schema defining the type used for the parameter.
	public var schema: ReferenceOr<SchemaObject>?

	/// Example of the parameter's potential value. The example SHOULD match the specified schema and encoding properties if present. The example field is mutually exclusive of the examples field. Furthermore, if referencing a schema that contains an example, the example value SHALL override the example provided by the schema. To represent public var examples of media types that cannot naturally be represented in JSON or YAML, a string value can contain the example with escaping where necessary.
	public var example: AnyValue?

	/// Examples of the parameter's potential value. Each example SHOULD contain a value in the correct format as specified in the parameter encoding. The examples field is mutually exclusive of the example field. Furthermore, if referencing a schema that contains an example, the examples value SHALL override the example provided by the schema.
	public var examples: OrderedDictionary<String, ReferenceOr<ExampleObject>>?

	/// A map containing the representations for the parameter. The key is the media type and the value describes it. The map MUST only contain one entry.
	public var content: ContentObject?

	public var specificationExtensions: SpecificationExtensions? = nil

	public init(description: String? = nil, required: Bool? = nil, deprecated: Bool? = nil, allowEmptyValue: Bool? = nil, style: ParameterObject.Style? = nil, explode: Bool? = nil, allowReserved: Bool? = nil, schema: ReferenceOr<SchemaObject>? = nil, example: AnyValue? = nil, examples: OrderedDictionary<String, ReferenceOr<ExampleObject>>? = nil, content: ContentObject? = nil) {
		self.description = description
		self.required = required
		self.deprecated = deprecated
		self.allowEmptyValue = allowEmptyValue
		self.style = style
		self.explode = explode
		self.allowReserved = allowReserved
		self.schema = schema
		self.example = example
		self.examples = examples
		self.content = content
	}
}

public extension [String: ReferenceOr<HeaderObject>] {

	static func encode(
		_ value: Encodable,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		schemas: inout OrderedDictionary<String, ReferenceOr<SchemaObject>>
	) throws -> OrderedDictionary<String, ReferenceOr<HeaderObject>> {
		try HeadersEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
			.encode(value, schemas: &schemas)
			.mapValues {
				.value($0)
			}
	}

	static func decode(
		_ type: Decodable.Type,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		schemas: inout OrderedDictionary<String, ReferenceOr<SchemaObject>>
	) throws -> OrderedDictionary<String, ReferenceOr<HeaderObject>> {
		try HeadersEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
			.decode(type, schemas: &schemas)
			.mapValues {
				.value($0)
			}
	}
}
