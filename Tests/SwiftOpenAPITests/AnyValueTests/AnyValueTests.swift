@testable import SwiftOpenAPI
import XCTest

class AnyValueTests: XCTestCase {

	func testInit() throws {
		let _ = AnyValue("hi")
		let _: AnyValue = nil
		let _: AnyValue = true
		let _: AnyValue = 10
		let _: AnyValue = 3.4
		let _: AnyValue = "hello"
		let _: AnyValue = ["hi", "there"]
		let _: AnyValue = ["hi": "there"]
	}

	func testEquality() throws {
		XCTAssertEqual(AnyValue(nilLiteral: ()), .null)
		XCTAssertEqual(true as AnyValue, .bool(true))
		XCTAssertEqual(2 as AnyValue, .int(2))
		XCTAssertEqual(2.0 as AnyValue, .double(2))
		XCTAssertEqual("hi" as AnyValue, .string("hi"))
		XCTAssertEqual(["hi": 2] as AnyValue, .object(["hi": .int(2)]))
		XCTAssertEqual(["hi", "there"] as AnyValue, .array([.string("hi"), .string("there")]))
		XCTAssertEqual(["hi": 1] as AnyValue, .object(["hi": .int(1)]))
		XCTAssertEqual(["hi": 1.2] as AnyValue, .object(["hi": .double(1.2)]))
		XCTAssertEqual([1] as AnyValue, .array([.int(1)]))
		XCTAssertEqual([1.2] as AnyValue, .array([.double(1.2)]))
		XCTAssertEqual([true] as AnyValue, .array([.bool(true)]))
	}

	func testVoidDescription() {
		XCTAssertEqual(String(describing: AnyValue(nilLiteral: ())), "nil")
	}

	func testJSONDecoding() throws {
		let json = """
		{
		    "boolean": true,
		    "integer": 1,
		    "string": "string",
		    "array": [1, 2, 3],
		    "nested": {
		        "a": "alpha",
		        "b": "bravo",
		        "c": "charlie"
		    }
		}
		""".data(using: .utf8)!

		let decoder = JSONDecoder()
		let dictionary = try decoder.decode([String: AnyValue].self, from: json)

		XCTAssertEqual(dictionary["boolean"], true)
		XCTAssertEqual(dictionary["integer"], 1)
		XCTAssertEqual(dictionary["string"], "string")
		XCTAssertEqual(dictionary["array"], [1, 2, 3])
		XCTAssertEqual(dictionary["nested"], ["a": "alpha", "b": "bravo", "c": "charlie"])
	}

	func testJSONEncoding() throws {
		let dictionary: [String: AnyValue] = [
			"boolean": true,
			"integer": 1,
			"string": "string",
			"array": [1, 2, 3],
			"nested": [
				"a": "alpha",
				"b": "bravo",
				"c": "charlie",
			],
		]

		let result = try testStringFromEncoding(of: dictionary)

		assertJSONEquivalent(
			result,
			"""
			{
			  "array" : [
			    1,
			    2,
			    3
			  ],
			  "boolean" : true,
			  "integer" : 1,
			  "nested" : {
			    "a" : "alpha",
			    "b" : "bravo",
			    "c" : "charlie"
			  },
			  "string" : "string"
			}
			"""
		)
	}

	let testEncoder: JSONEncoder = {
		let encoder = JSONEncoder()
		if #available(macOS 10.13, *) {
			encoder.outputFormatting = .sortedKeys
		}
		return encoder
	}()

	func test_encodeNil() throws {
		let data = try JSONEncoder().encode(Wrapper(value: nil as AnyValue))

		let string = String(data: data, encoding: .utf8)

		XCTAssertEqual(string, #"{"value":null}"#)
	}

	func test_encodeBool() throws {
		let data = try JSONEncoder().encode(Wrapper(value: false as AnyValue))

		let string = String(data: data, encoding: .utf8)

		XCTAssertEqual(string, #"{"value":false}"#)
	}

	func test_encodeInt() throws {
		let data = try JSONEncoder().encode(Wrapper(value: 2 as AnyValue))

		let string = String(data: data, encoding: .utf8)

		XCTAssertEqual(string, #"{"value":2}"#)
	}

	func test_encodeString() throws {
		let data = try JSONEncoder().encode(Wrapper(value: "hi" as AnyValue))

		let string = String(data: data, encoding: .utf8)

		XCTAssertEqual(string, #"{"value":"hi"}"#)
	}

	func test_encodeURL() throws {
		let data = try JSONEncoder().encode(Wrapper(value: AnyValue.string("https://hello.com")))

		let string = String(data: data, encoding: .utf8)

		XCTAssertEqual(string, #"{"value":"https:\/\/hello.com"}"#)
	}
}

private struct Wrapper: Codable {
	let value: AnyValue
}
