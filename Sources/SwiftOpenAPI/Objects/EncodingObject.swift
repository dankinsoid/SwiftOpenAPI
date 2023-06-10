import Foundation

public struct EncodingObject: Codable, Equatable, SpecificationExtendable {

	/// The Content-Type for encoding a specific property. Default value depends on the property type: for object - application/json; for array – the default is defined based on the inner type; for all other cases the default is application/octet-stream. The value can be a specific media type (e.g. application/json), a wildcard media type (e.g. image/*), or a comma-separated list of the two types.
	public var contentType: MediaType?

	/// A map allowing additional information to be provided as headers, for example Content-Disposition. Content-Type is described separately and SHALL be ignored in this section. This property SHALL be ignored if the request body media type is not a multipart.
	public var headers: OrderedDictionary<String, ReferenceOr<HeaderObject>>?

	/// Describes how a specific property value will be serialized depending on its type. See Parameter Object for details on the style property. The behavior follows the same values as query parameters, including default values. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded or multipart/form-data. If a value is explicitly defined, then the value of contentType (implicit or explicit) SHALL be ignored.
	public var style: String?

	/// When this is true, property values of type array or object generate separate parameters for each value of the array, or key-value-pair of the map. For other types of properties this property has no effect. When style is form, the default value is true. For all other styles, the default value is false. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded or multipart/form-data. If a value is explicitly defined, then the value of contentType (implicit or explicit) SHALL be ignored.
	public var explode: Bool?

	/// Determines whether the parameter value SHOULD allow reserved characters, as defined by RFC3986 :/?#[]@!$&'()*+,;= to be included without percent-encoding. The default value is false. This property SHALL be ignored if the request body media type is not application/x-www-form-urlencoded or multipart/form-data. If a value is explicitly defined, then the value of contentType (implicit or explicit) SHALL be ignored.
	public var allowReserved: Bool?

	public var specificationExtensions: SpecificationExtensions? = nil

	public init(contentType: MediaType? = nil, headers: OrderedDictionary<String, ReferenceOr<HeaderObject>>? = nil, style: String? = nil, explode: Bool? = nil, allowReserved: Bool? = nil) {
		self.contentType = contentType
		self.headers = headers
		self.style = style
		self.explode = explode
		self.allowReserved = allowReserved
	}
}
