import Foundation
import OpenAPIKit

public protocol OpenAPIDescriptionType {

	var openAPISchemeDescription: String? { get }
	var schemePropertyDescriptions: [String: String] { get }
}

extension String: OpenAPIDescriptionType {

	public var openAPISchemeDescription: String? { self }
	public var schemePropertyDescriptions: [String: String] { [:] }
}

public struct OpenAPIDescription<Key: CodingKey>: OpenAPIDescriptionType, ExpressibleByStringInterpolation {

	public var openAPISchemeDescription: String?
	public var schemePropertyDescriptions: [String: String] = [:]

	public init(_ openAPISchemeDescription: String? = nil) {
		self.openAPISchemeDescription = openAPISchemeDescription
	}

	public init(stringLiteral value: String) {
		openAPISchemeDescription = value
	}

	public init(stringInterpolation: DefaultStringInterpolation) {
		openAPISchemeDescription = String(stringInterpolation: stringInterpolation)
	}

	public func add(for key: Key, _ description: String) -> OpenAPIDescription {
		var result = self
		result.schemePropertyDescriptions[key.stringValue] = description
		return result
	}
}

extension JSONSchema {

	func with(description: OpenAPIDescriptionType?) -> JSONSchema {
		guard let description else { return self }
		var result = description.openAPISchemeDescription.map { with(description: $0) } ?? self
		switch result {
		case let .object(context, object):
			var props = object.properties
			for (key, value) in description.schemePropertyDescriptions {
				if let schema = props[key] {
					props[key] = schema.with(description: value)
				}
			}
			result = .object(
				context,
				ObjectContext(
					properties: props,
					additionalProperties: object.additionalProperties,
					maxProperties: object.maxProperties,
					minProperties: object.minProperties
				)
			)
		default:
			break
		}
		return result
	}
	
	func with(description: String) -> JSONSchema {
		switch self {
		case .boolean(let context):
			return .boolean(context.with(description: description))
		case .object(let contextA, let contextB):
			return .object(contextA.with(description: description), contextB)
		case .array(let contextA, let contextB):
			return .array(contextA.with(description: description), contextB)
		case .number(let context, let contextB):
			return .number(context.with(description: description), contextB)
		case .integer(let context, let contextB):
			return .integer(context.with(description: description), contextB)
		case .string(let context, let contextB):
			return .string(context.with(description: description), contextB)
		case .fragment(let context):
			return .fragment(context.with(description: description))
		case .all(of: let fragments, core: let core):
			return .all(of: fragments, core: core.with(description: description))
		case .one(of: let schemas, core: let core):
			return .one(of: schemas, core: core.with(description: description))
		case .any(of: let schemas, core: let core):
			return .any(of: schemas, core: core.with(description: description))
		case .not(let schema, core: let core):
			return .not(schema, core: core.with(description: description))
		case .reference:
			return self
		}
	}

}

extension JSONSchema.CoreContext {
	
	func with(description: String) -> JSONSchema.CoreContext<Format> {
		return .init(
			format: format,
			required: required,
			nullable: nullable,
			permissions: permissions,
			deprecated: deprecated,
			title: title,
			description: description,
			discriminator: discriminator,
			externalDocs: externalDocs,
			allowedValues: allowedValues,
			defaultValue: defaultValue,
			example: example
		)
	}
}

extension OpenAPI.Parameter.Array {

	func with(description: OpenAPIDescriptionType?) -> OpenAPI.Parameter.Array {
		guard let description else { return self }
		var result = self
		for (key, value) in description.schemePropertyDescriptions {
			guard let i = result.firstIndex(where: { $0.b?.name == key }), let parameter = result[i].b else { continue }
			result[i] = .b(
				OpenAPI.Parameter(
					name: parameter.name,
					context: parameter.context,
					schemaOrContent: parameter.schemaOrContent,
					description: value,
					deprecated: parameter.deprecated,
					vendorExtensions: parameter.vendorExtensions
				)
			)
		}
		return result
	}
}

extension OpenAPI.Header.Map {

	func with(description: OpenAPIDescriptionType?) -> OpenAPI.Header.Map {
		guard let description else { return self }
		var result = self
		for (key, value) in description.schemePropertyDescriptions {
			if let header = result[key]?.b, header.description?.nilIfEmpty == nil {
				result[key] = .b(
					OpenAPI.Header(
						schemaOrContent: header.schemaOrContent,
						description: value,
						required: header.required,
						deprecated: header.deprecated,
						vendorExtensions: header.vendorExtensions
					)
				)
			}
		}
		return result
	}
}
