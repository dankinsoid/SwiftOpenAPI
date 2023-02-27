import Foundation

/// The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is a superset of the JSON Schema Specification Draft 2020-12.
///
/// For more information about the properties, see JSON Schema Core and JSON Schema Validation.
///
/// Unless stated otherwise, the property definitions follow those of JSON Schema and do not add any additional semantics. Where JSON Schema indicates that behavior is defined by the application (e.g. for annotations), OAS also defers the definition of semantics to the application consuming the OpenAPI document.
public struct SchemaObject: Codable, Equatable, SpecificationExtendable {
    
    /// Adds support for polymorphism. The discriminator is an object name that is used to differentiate between other schemas which may satisfy the payload description. See Composition and Inheritance for more details.
    public var discriminator: DiscriminatorObject?
    
    /// This MAY be used only on properties schemas. It has no effect on root schemas. Adds additional metadata to describe the XML representation of this property.
    public var xml: XMLObject?
    
    /// Additional external documentation for this schema.
    public var externalDocs: ExternalDocumentationObject?
    
    /// A free-form property to include an example of an instance for this schema. To represent examples that cannot be naturally represented in JSON or YAML, a string value can be used to contain the example with escaping where necessary.
    
    @available(*, deprecated, message: "The example property has been deprecated in favor of the JSON Schema examples keyword. Use of example is discouraged, and later versions of this specification may remove it.")
    public var example: AnyValue?
    
    
    public init(discriminator: DiscriminatorObject? = nil, xml: XMLObject? = nil, externalDocs: ExternalDocumentationObject? = nil) {
        self.discriminator = discriminator
        self.xml = xml
        self.externalDocs = externalDocs
    }
}
