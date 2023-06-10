import Foundation

/// Range expression that supports all range operators
public struct AnyRange<Bound: Comparable>: RangeExpression {

	public let lowerBound: Bound?
	public let upperBound: Bound?
	public let include: Set<RangeEdge>

	public init(lowerBound: Bound?, upperBound: Bound?, include: Set<RangeEdge>) {
		self.lowerBound = lowerBound.map { lowerBound in
			upperBound.map { min(lowerBound, $0) } ?? lowerBound
		}
		self.upperBound = upperBound.map { upperBound in
			lowerBound.map { min(upperBound, $0) } ?? upperBound
		}
		self.include = include
	}

	public subscript(_ edge: RangeEdge) -> Bound? {
		switch edge {
		case .lower: return lowerBound
		case .upper: return upperBound
		}
	}

	public func relative<C: Collection>(to collection: C) -> Range<Bound> where Bound == C.Index {
		switch (lowerBound, upperBound, include.contains(.lower), include.contains(.upper)) {
		case (.some(let lower), let .some(upper), true, true):
			return (lower ... upper).relative(to: collection)
		case (.some(let lower), let .some(upper), false, true):
			return upLowerBound((lower ... upper).relative(to: collection), in: collection)
		case (.some(let lower), let .some(upper), true, false):
			return (lower ..< upper).relative(to: collection)
		case (.some(let lower), let .some(upper), false, false):
			return upLowerBound((lower ..< upper).relative(to: collection), in: collection)
		case (.some(let lower), .none, true, _):
			return (lower...).relative(to: collection)
		case (.some(let lower), .none, false, _):
			return upLowerBound((lower...).relative(to: collection), in: collection)
		case (.none, let .some(upper), _, true):
			return (...upper).relative(to: collection)
		case (.none, let .some(upper), _, false):
			return (..<upper).relative(to: collection)
		case (.none, .none, _, _):
			return collection.startIndex ..< collection.endIndex
		}
	}

	public func contains(_ element: Bound) -> Bool {
		let isUpper: Bool
		if let lowerBound {
			isUpper = include.contains(.lower) ? element >= lowerBound : element > lowerBound
		} else {
			isUpper = true
		}
		let isLower: Bool
		if let upperBound {
			isLower = include.contains(.upper) ? element <= upperBound : element < upperBound
		} else {
			isLower = true
		}
		return isLower && isUpper
	}

	public static var any: AnyRange {
		AnyRange(lowerBound: nil, upperBound: nil, include: [])
	}

	private func upLowerBound<C: Collection>(_ range: Range<Bound>, in collection: C) -> Range<Bound> where Bound == C.Index {
		guard range.upperBound > range.lowerBound else {
			return range
		}
		return collection.index(after: range.lowerBound) ..< range.upperBound
	}
}

@_disfavoredOverload
public func ... <Bound: Comparable>(_ lhs: Bound, _ rhs: Bound) -> AnyRange<Bound> {
	AnyRange(lowerBound: lhs, upperBound: rhs, include: [.lower, .upper])
}

@_disfavoredOverload
public func ..< <Bound: Comparable>(_ lhs: Bound, _ rhs: Bound) -> AnyRange<Bound> {
	AnyRange(lowerBound: lhs, upperBound: rhs, include: [.lower])
}

@_disfavoredOverload
public postfix func ... <Bound: Comparable>(_ lhs: Bound) -> AnyRange<Bound> {
	AnyRange(lowerBound: lhs, upperBound: nil, include: [.lower])
}

@_disfavoredOverload
public prefix func ..< <Bound: Comparable>(_ rhs: Bound) -> AnyRange<Bound> {
	AnyRange(lowerBound: nil, upperBound: rhs, include: [])
}

@_disfavoredOverload
public prefix func ... <Bound: Comparable>(_ rhs: Bound) -> AnyRange<Bound> {
	AnyRange(lowerBound: nil, upperBound: rhs, include: [.upper])
}

public enum RangeEdge: Hashable {

	case lower, upper
}
