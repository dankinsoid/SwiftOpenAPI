import Foundation

/// Describes the operations available on a single path. A Path Item MAY be empty, due to ACL constraints. The path itself is still exposed to the documentation viewer but they will not know which operations and parameters are available.
public struct PathItemObject: Codable, Equatable, SpecificationExtendable {

	/// String summary, intended to apply to all operations in this path.
	public var summary: String?

	/// String description, intended to apply to all operations in this path. CommonMark syntax MAY be used for rich text representation.
	public var description: String?

	public var operations: [Key: OperationObject]

	/// An alternative server array to service all operations in this path.
	public var servers: [ServerObject]?

	/// A list of parameters that are applicable for all the operations described under this path. These parameters can be overridden at the operation level, but cannot be removed there. The list MUST NOT include duplicated parameters. A unique parameter is defined by a combination of a name and location. The list can use the Reference Object to link to parameters that are defined at the OpenAPI Object's components/parameters.
	public var parameters: [ReferenceOr<ParameterObject>]?

	public var specificationExtensions: SpecificationExtensions? = nil

	public init(
		summary: String? = nil,
		description: String? = nil,
		servers: [ServerObject]? = nil,
		parameters: [ReferenceOr<ParameterObject>]? = nil,
		_ operations: [PathItemObject.Key: OperationObject]
	) {
		self.summary = summary
		self.description = description
		self.operations = operations
		self.servers = servers
		self.parameters = parameters
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		summary = try container.decodeIfPresent(String.self, forKey: .field(.summary))
		description = try container.decodeIfPresent(String.self, forKey: .field(.description))
		servers = try container.decodeIfPresent([ServerObject].self, forKey: .field(.servers))
		parameters = try container.decodeIfPresent([ReferenceOr<ParameterObject>].self, forKey: .field(.parameters))
		operations = [:]
		specificationExtensions = try SpecificationExtensions(from: decoder)

		for method in container.allKeys.compactMap(\.method) {
			operations[method] = try container.decodeIfPresent(OperationObject.self, forKey: .method(method))
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(summary, forKey: .field(.summary))
		try container.encodeIfPresent(description, forKey: .field(.description))
		try container.encodeIfPresent(servers, forKey: .field(.servers))
		try container.encodeIfPresent(parameters, forKey: .field(.parameters))
		for (method, operation) in operations {
			try container.encode(operation, forKey: .method(method))
		}
		try specificationExtensions.encode(to: encoder)
	}

	public enum CodingKeys: CodingKey {
		case field(Field)
		case method(Method)

		public var stringValue: String {
			switch self {
			case let .field(field):
				return field.rawValue
			case let .method(method):
				return method.rawValue
			}
		}

		public var method: Method? {
			switch self {
			case .field:
				return nil
			case let .method(method):
				return method
			}
		}

		public var intValue: Int? { nil }

		public init?(stringValue: String) {
			if let field = Field(rawValue: stringValue) {
				self = .field(field)
			} else {
				self = .method(PathItemObject.Method(rawValue: stringValue))
			}
		}

		public init?(intValue _: Int) {
			nil
		}

		public enum Field: String {
			case summary
			case description
			case servers
			case parameters
		}
	}
}

extension PathItemObject: ExpressibleByDictionary {
	public typealias Key = Method
	public typealias Value = OperationObject

	public init(dictionaryElements elements: [(Key, Value)]) {
		self.init(Dictionary(elements) { _, new in new })
	}

	public subscript(key: Method) -> OperationObject? {
		get {
			operations[key]
		}
		set {
			operations[key] = newValue
		}
	}

	public struct Method: LosslessStringConvertible, RawRepresentable, Codable, Hashable {
		public let rawValue: String
		public var description: String { rawValue }

		public init(_ description: String) {
			rawValue = description.lowercased()
		}

		public init(rawValue: String) {
			self.init(rawValue)
		}

		public init(from decoder: Decoder) throws {
			try self.init(String(from: decoder))
		}

		public func encode(to encoder: Encoder) throws {
			try rawValue.encode(to: encoder)
		}

		public static let get = Method("get")
		public static let put = Method("put")
		public static let post = Method("post")
		public static let delete = Method("delete")
		public static let options = Method("options")
		public static let head = Method("head")
		public static let patch = Method("patch")
		public static let trace = Method("trace")
	}
}

public protocol ExpressibleByPathItemObject {
	init(pathItemObject: PathItemObject)
}

extension PathItemObject: ExpressibleByPathItemObject {
	public init(pathItemObject: PathItemObject) {
		self = pathItemObject
	}
}

extension ReferenceOr<PathItemObject>: ExpressibleByPathItemObject {
	public init(pathItemObject: PathItemObject) {
		self = .value(pathItemObject)
	}
}

public extension ExpressibleByPathItemObject {
	/// A definition of a GET operation on this path.
	static func get(
		summary: String? = nil,
		description: String? = nil,
		servers: [ServerObject] = [],
		parameters: [ReferenceOr<ParameterObject>] = [],
		_ operation: OperationObject
	) -> Self {
		Self(pathItemObject: PathItemObject(summary: summary, description: description, servers: servers, parameters: parameters, [.get: operation]))
	}

	/// A definition of a PUT operation on this path.
	static func put(
		summary: String? = nil,
		description: String? = nil,
		servers: [ServerObject] = [],
		parameters: [ReferenceOr<ParameterObject>] = [],
		_ operation: OperationObject
	) -> Self {
		Self(pathItemObject: PathItemObject(summary: summary, description: description, servers: servers, parameters: parameters, [.put: operation]))
	}

	/// A definition of a POST operation on this path.
	static func post(
		summary: String? = nil,
		description: String? = nil,
		servers: [ServerObject] = [],
		parameters: [ReferenceOr<ParameterObject>] = [],
		_ operation: OperationObject
	) -> Self {
		Self(pathItemObject: PathItemObject(summary: summary, description: description, servers: servers, parameters: parameters, [.post: operation]))
	}

	/// A definition of a DELETE operation on this path.
	static func delete(
		summary: String? = nil,
		description: String? = nil,
		servers: [ServerObject] = [],
		parameters: [ReferenceOr<ParameterObject>] = [],
		_ operation: OperationObject
	) -> Self {
		Self(pathItemObject: PathItemObject(summary: summary, description: description, servers: servers, parameters: parameters, [.delete: operation]))
	}

	/// A definition of a OPTIONS operation on this path.
	static func options(
		summary: String? = nil,
		description: String? = nil,
		servers: [ServerObject] = [],
		parameters: [ReferenceOr<ParameterObject>] = [],
		_ operation: OperationObject
	) -> Self {
		Self(pathItemObject: PathItemObject(summary: summary, description: description, servers: servers, parameters: parameters, [.options: operation]))
	}

	/// A definition of a HEAD operation on this path.
	static func head(
		summary: String? = nil,
		description: String? = nil,
		servers: [ServerObject] = [],
		parameters: [ReferenceOr<ParameterObject>] = [],
		_ operation: OperationObject
	) -> Self {
		Self(pathItemObject: PathItemObject(summary: summary, description: description, servers: servers, parameters: parameters, [.head: operation]))
	}

	/// A definition of a PATCH operation on this path.
	static func patch(
		summary: String? = nil,
		description: String? = nil,
		servers: [ServerObject] = [],
		parameters: [ReferenceOr<ParameterObject>] = [],
		_ operation: OperationObject
	) -> Self {
		Self(pathItemObject: PathItemObject(summary: summary, description: description, servers: servers, parameters: parameters, [.patch: operation]))
	}

	/// A definition of a TRACE operation on this path.
	static func trace(
		summary: String? = nil,
		description: String? = nil,
		servers: [ServerObject] = [],
		parameters: [ReferenceOr<ParameterObject>] = [],
		_ operation: OperationObject
	) -> Self {
		Self(pathItemObject: PathItemObject(summary: summary, description: description, servers: servers, parameters: parameters, [.trace: operation]))
	}
}
