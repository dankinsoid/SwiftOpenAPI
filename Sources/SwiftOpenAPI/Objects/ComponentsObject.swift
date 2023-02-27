import Foundation

/// Holds a set of reusable objects for different aspects of the OAS. All objects defined within the components object will have no effect on the API unless they are explicitly referenced from properties outside the components object.
public struct ComponentsObject: Codable, Equatable, SpecificationExtendable {
    
    /// An object to hold reusable Schema Objects.
    public var schemas: [String: SchemaObject]?
    
    /// An object to hold reusable Response Objects.
    public var responses: [String: ReferenceOr<ResponseObject>]?
    
    /// An object to hold reusable Parameter Objects.
    public var parameters: [String: ReferenceOr<ParameterObject>]?
    
    /// An object to hold reusable Example Objects.
    public var examples: [String: ReferenceOr<ExampleObject>]?
    
    /// An object to hold reusable Request Body Objects.
    public var requestBodies: [String: ReferenceOr<RequestBodyObject>]?
    
    /// An object to hold reusable Header Objects.
    public var headers: [String: ReferenceOr<HeaderObject>]?
    
    /// An object to hold reusable Security Scheme Objecvar ts.
    public var securitySchemes: [String: ReferenceOr<SecuritySchemeObject>]?
    
    /// An object to hold reusable Link Objects.
    public var links: [String: ReferenceOr<LinkObject>]?
    
    /// An object to hold reusable Callback Objects.
    public var callbacks: [String: ReferenceOr<CallbackObject>]?
    
    /// An object to hold reusable Path Item Object.
    public var pathItems: [String: ReferenceOr<PathItemObject>]?
    
    public init(schemas: [String: SchemaObject]? = nil, responses: [String: ReferenceOr<ResponseObject>]? = nil, parameters: [String: ReferenceOr<ParameterObject>]? = nil, examples: [String: ReferenceOr<ExampleObject>]? = nil, requestBodies: [String: ReferenceOr<RequestBodyObject>]? = nil, headers: [String: ReferenceOr<HeaderObject>]? = nil, securitySchemes: [String: ReferenceOr<SecuritySchemeObject>]? = nil, links: [String: ReferenceOr<LinkObject>]? = nil, callbacks: [String: ReferenceOr<CallbackObject>]? = nil, pathItems: [String: ReferenceOr<PathItemObject>]? = nil) {
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
    }
}
