import Foundation

public struct DateEncodingFormat {
    
    public let dataFormat: DataFormat
    public let encode: (Date, inout SingleValueEncodingContainer) throws -> Void
}

public extension DateEncodingFormat {
    
    static var `default`: DateEncodingFormat = .dateTime
    
    /// full-date notation as defined by RFC 3339, section 5.6, for example, 2017-07-21
    static var date: DateEncodingFormat {
        DateEncodingFormat(dataFormat: .date) { date, encoder in
            dateFormatter.dateFormat = "yyyy-MM-dd"
            try encoder.encode(dateFormatter.string(from: date))
        }
    }
    
    /// the date-time notation as defined by RFC 3339, section 5.6, for example, 2017-07-21T17:32:28Z
    static var dateTime: DateEncodingFormat {
        DateEncodingFormat(dataFormat: .dateTime) { date, encoder in
            try encoder.encode(isoFormatter.string(from: date))
        }
    }
    
    /// the interval between the date value and 00:00:00 UTC on 1 January 1970.
    static var timestamp: DateEncodingFormat {
        DateEncodingFormat(dataFormat: "timestamp") { date, encoder in
            try encoder.encode(date.timeIntervalSince1970)
        }
    }
    
    static func custom(_ format: String) -> DateEncodingFormat {
        DateEncodingFormat(dataFormat: DataFormat(format)) { date, encoder in
            dateFormatter.dateFormat = format
            try encoder.encode(dateFormatter.string(from: date))
        }
    }
    
    static func custom(
        _ dataFormat: DataFormat,
        encode: @escaping (Date, inout SingleValueEncodingContainer) throws -> Void
    ) -> DateEncodingFormat {
        DateEncodingFormat(dataFormat: dataFormat, encode: encode)
    }
    
    static func custom(
        _ dataFormat: DataFormat,
        formatter: DateFormatter
    ) -> DateEncodingFormat {
        DateEncodingFormat(dataFormat: dataFormat) { date, encoder in
        		try encoder.encode(formatter.string(from: date))
    		}
    }
}

private let isoFormatter = ISO8601DateFormatter()
private let dateFormatter = DateFormatter()
