import Foundation

/// Holds a set of reusable objects for different aspects of the OAS. All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object.
public struct ComponentsObject: Codable, Equatable, SpecificationExtendable {

	/// An object to hold reusable Schema Objects.
	public var schemas: OrderedDictionary<String, ReferenceOr<SchemaObject>>?

	/// An object to hold reusable Response Objects.
	public var responses: OrderedDictionary<String, ReferenceOr<ResponseObject>>?

	/// An object to hold reusable Parameter Objects.
	public var parameters: OrderedDictionary<String, ReferenceOr<ParameterObject>>?

	/// An object to hold reusable Example Objects.
	public var examples: OrderedDictionary<String, ReferenceOr<ExampleObject>>?

	/// An object to hold reusable Request Body Objects.
	public var requestBodies: OrderedDictionary<String, ReferenceOr<RequestBodyObject>>?

	/// An object to hold reusable Header Objects.
	public var headers: OrderedDictionary<String, ReferenceOr<HeaderObject>>?

	/// An object to hold reusable Security Scheme Objecvar ts.
	public var securitySchemes: OrderedDictionary<String, ReferenceOr<SecuritySchemeObject>>?

	/// An object to hold reusable Link Objects.
	public var links: OrderedDictionary<String, ReferenceOr<LinkObject>>?

	/// An object to hold reusable Callback Objects.
	public var callbacks: OrderedDictionary<String, ReferenceOr<CallbackObject>>?

	/// An object to hold reusable Path Item Object.
	public var pathItems: OrderedDictionary<String, ReferenceOr<PathItemObject>>?

	public var specificationExtensions: SpecificationExtensions? = nil

	public init(
		schemas: OrderedDictionary<String, ReferenceOr<SchemaObject>>? = nil,
		responses: OrderedDictionary<String, ReferenceOr<ResponseObject>>? = nil,
		parameters: OrderedDictionary<String, ReferenceOr<ParameterObject>>? = nil,
		examples: OrderedDictionary<String, ReferenceOr<ExampleObject>>? = nil,
		requestBodies: OrderedDictionary<String, ReferenceOr<RequestBodyObject>>? = nil,
		headers: OrderedDictionary<String, ReferenceOr<HeaderObject>>? = nil,
		securitySchemes: OrderedDictionary<String, ReferenceOr<SecuritySchemeObject>>? = nil,
		links: OrderedDictionary<String, ReferenceOr<LinkObject>>? = nil,
		callbacks: OrderedDictionary<String, ReferenceOr<CallbackObject>>? = nil,
		pathItems: OrderedDictionary<String, ReferenceOr<PathItemObject>>? = nil,
		specificationExtensions: SpecificationExtensions = [:]
	) {
		self.schemas = schemas
		self.responses = responses
		self.parameters = parameters
		self.examples = examples
		self.requestBodies = requestBodies
		self.headers = headers
		self.securitySchemes = securitySchemes
		self.links = links
		self.callbacks = callbacks
		self.pathItems = pathItems
		self.specificationExtensions = specificationExtensions
	}
}
