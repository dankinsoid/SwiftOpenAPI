import Foundation

public protocol OpenAPIDescriptionType {

	var openAPISchemeDescription: String? { get }
	var schemePropertyDescriptions: [String: String] { get }
}

extension String: OpenAPIDescriptionType {
    
    public var openAPISchemeDescription: String? { self }
    public var schemePropertyDescriptions: [String: String] { [:] }
}

extension OpenAPIDescriptionType {
    
    public var asStringOpenAPIDescription: OpenAPIDescription<String> {
        OpenAPIDescription(
            openAPISchemeDescription: openAPISchemeDescription,
            schemePropertyDescriptions: schemePropertyDescriptions
        )
    }
}

public struct OpenAPIDescription<Key>: OpenAPIDescriptionType, ExpressibleByStringInterpolation, Equatable {

	public var openAPISchemeDescription: String?
	public var schemePropertyDescriptions: [String: String] = [:]

	public init(_ openAPISchemeDescription: String? = nil) {
		self.openAPISchemeDescription = openAPISchemeDescription
	}
    
    init(
        openAPISchemeDescription: String?,
        schemePropertyDescriptions: [String: String]
    ) {
        self.openAPISchemeDescription = openAPISchemeDescription
        self.schemePropertyDescriptions = schemePropertyDescriptions
    }

	public init(stringLiteral value: String) {
		openAPISchemeDescription = value
	}

	public init(stringInterpolation: DefaultStringInterpolation) {
		openAPISchemeDescription = String(stringInterpolation: stringInterpolation)
	}
}

extension OpenAPIDescription where Key: CodingKey {
    
    public func add(for key: Key, _ description: String) -> OpenAPIDescription {
        var result = self
        result.schemePropertyDescriptions[key.stringValue] = description
        return result
    }
}

extension OpenAPIDescription where Key == String {
    
    public func add(for key: Key, _ description: String) -> OpenAPIDescription {
        var result = self
        result.schemePropertyDescriptions[key] = description
        return result
    }
}

extension OpenAPIDescription where Key: RawRepresentable, Key.RawValue == String {
    
    @_disfavoredOverload
    public func add(for key: Key, _ description: String) -> OpenAPIDescription {
        var result = self
        result.schemePropertyDescriptions[key.rawValue] = description
        return result
    }
}

extension SchemaObject {

	func with(description: OpenAPIDescriptionType?) -> SchemaObject {
		guard let description else { return self }
		var result = self
		result.description = description.openAPISchemeDescription ?? result.description
		switch result.context {
		case var .object(context):
			for (key, value) in description.schemePropertyDescriptions {
				if case var .value(scheme) = context.properties?[key] {
					scheme.description = value
					context.properties?[key] = .value(scheme)
				}
			}
			result.context = .object(context)
		default:
			break
		}
		return result
	}
}

extension ReferenceOr<SchemaObject> {

	func with(description: OpenAPIDescriptionType?) -> ReferenceOr<SchemaObject> {
		guard let description else { return self }
		switch self {
		case let .value(scheme):
			return .value(scheme.with(description: description))
		default:
			return self
		}
	}
}

extension [ParameterObject] {

	func with(description: OpenAPIDescriptionType?) -> [ParameterObject] {
		guard let description else { return self }
		var result = self
		for (key, value) in description.schemePropertyDescriptions {
			guard let i = result.firstIndex(where: { $0.name == key }) else { continue }
			result[i].description = value
		}
		return result
	}
}

extension OrderedDictionary<String, HeaderObject> {

	func with(description: OpenAPIDescriptionType?) -> OrderedDictionary<String, HeaderObject> {
		guard let description else { return self }
		var result = self
		for (key, value) in description.schemePropertyDescriptions {
			result[key]?.description = value
		}
		return result
	}
}
