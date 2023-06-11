import Foundation

public typealias ComponentsMap<T> = OrderedDictionary<String, ReferenceOr<T>>

/// Holds a set of reusable objects for different aspects of the OAS. All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object.
public struct ComponentsObject: Codable, Equatable, SpecificationExtendable {

	/// An object to hold reusable Schema Objects.
	public var schemas: ComponentsMap<SchemaObject>?

	/// An object to hold reusable Response Objects.
	public var responses: ComponentsMap<ResponseObject>?

	/// An object to hold reusable Parameter Objects.
	public var parameters: ComponentsMap<ParameterObject>?

	/// An object to hold reusable Example Objects.
	public var examples: ComponentsMap<ExampleObject>?

	/// An object to hold reusable Request Body Objects.
	public var requestBodies: ComponentsMap<RequestBodyObject>?

	/// An object to hold reusable Header Objects.
	public var headers: ComponentsMap<HeaderObject>?

	/// An object to hold reusable Security Scheme Objecvar ts.
	public var securitySchemes: ComponentsMap<SecuritySchemeObject>?

	/// An object to hold reusable Link Objects.
	public var links: ComponentsMap<LinkObject>?

	/// An object to hold reusable Callback Objects.
	public var callbacks: ComponentsMap<CallbackObject>?

	/// An object to hold reusable Path Item Object.
	public var pathItems: ComponentsMap<PathItemObject>?

	public var specificationExtensions: SpecificationExtensions? = nil

	public init(
		schemas: ComponentsMap<SchemaObject>? = nil,
		responses: ComponentsMap<ResponseObject>? = nil,
		parameters: ComponentsMap<ParameterObject>? = nil,
		examples: ComponentsMap<ExampleObject>? = nil,
		requestBodies: ComponentsMap<RequestBodyObject>? = nil,
		headers: ComponentsMap<HeaderObject>? = nil,
		securitySchemes: ComponentsMap<SecuritySchemeObject>? = nil,
		links: ComponentsMap<LinkObject>? = nil,
		callbacks: ComponentsMap<CallbackObject>? = nil,
		pathItems: ComponentsMap<PathItemObject>? = nil,
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
