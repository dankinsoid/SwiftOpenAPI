import Foundation

public struct DateEncodingFormat {

	public let schema: SchemaObject
	public let encode: (Date, inout SingleValueEncodingContainer) throws -> Void
}

public extension DateEncodingFormat {

    static var `default`: DateEncodingFormat {
        get {
            defaultDateEncodingFormat.wrappedValue
        }
        set {
            defaultDateEncodingFormat.wrappedValue = newValue
        }
    }

	/// full-date notation as defined by RFC 3339, section 5.6, for example, 2017-07-21
	static var date: DateEncodingFormat {
		DateEncodingFormat(schema: .string(format: .date)) { date, encoder in
			try encoder.encode(DateEncodingFormat.date(date))
		}
	}

	/// the date-time notation as defined by RFC 3339, section 5.6, for example, 2017-07-21T17:32:28Z
	static var dateTime: DateEncodingFormat {
		DateEncodingFormat(schema: .string(format: .dateTime)) { date, encoder in
			try encoder.encode(DateEncodingFormat.dateTime(date))
		}
	}

	/// the interval between the date value and 00:00:00 UTC on 1 January 1970.
	static var timestamp: DateEncodingFormat {
		DateEncodingFormat(schema: .number(format: "timestamp")) { date, encoder in
			try encoder.encode(date.timeIntervalSince1970)
		}
	}

	static func custom(_ format: String) -> DateEncodingFormat {
		DateEncodingFormat(schema: .string(format: DataFormat(format))) { date, encoder in
			dateFormatter.dateFormat = format
			try encoder.encode(dateFormatter.string(from: date))
		}
	}

	static func custom(
		_ schema: SchemaObject,
		encode: @escaping (Date, inout SingleValueEncodingContainer) throws -> Void
	) -> DateEncodingFormat {
		DateEncodingFormat(schema: schema, encode: encode)
	}

	static func custom(
		_ dataFormat: DataFormat,
		formatter: DateFormatter
	) -> DateEncodingFormat {
		DateEncodingFormat(schema: .string(format: dataFormat)) { date, encoder in
			try encoder.encode(formatter.string(from: date))
		}
	}
}

extension DateEncodingFormat {

	static func dateTime(_ date: Date) -> String {
		isoFormatter.string(from: date)
	}

	static func date(_ date: Date) -> String {
		dateFormatter.dateFormat = "yyyy-MM-dd"
		return dateFormatter.string(from: date)
	}
}

private let defaultDateEncodingFormat = Lock(DateEncodingFormat.dateTime)

private let isoFormatter = ISO8601DateFormatter()
private let dateFormatter = DateFormatter()
