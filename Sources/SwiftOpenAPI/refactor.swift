import Foundation

// public extension OpenAPIObject {
//
//    mutating func refactor() {
//        let base = MutatingRef(\OpenAPIObject.self)
////        refactor(
////            refs: [
////            		MutatingRef(<#T##keyPath: WritableKeyPath<Base, Value?>##WritableKeyPath<Base, Value?>#>)
////            ],
////            component: \.schemas
////        )
////        refactor(
////            refs: [
////                MutatingRef()
////            ],
////            component: \.responses
////        )
//
//        let ref = base.paths.object.parameters
//
//        let t = (\OpenAPIObject.paths?.value)(\.keys, { \.[$0] })
//
//    }
// }
//
// private extension OpenAPIObject {
//
//    mutating func refactor<T>(
//        refs: [MutatingRef<OpenAPIObject, ReferenceOr<T>>],
//        component: WritableKeyPath<ComponentsObject, [String: ReferenceOr<HeaderObject>]?>
//    ) {
//
//    }
// }
//
// @dynamicMemberLookup
// struct MutatingRef<Base, Value> {
//
//    let get: (Base) -> Value?
//    let set: (inout Base, Value) -> Void
//
//    init(get: @escaping (Base) -> Value?, set: @escaping (inout Base, Value) -> Void) {
//        self.get = get
//        self.set = set
//    }
//
//    init(_ keyPath: WritableKeyPath<Base, Value>) {
//        self.init { base in
//            base[keyPath: keyPath]
//        } set: { base, value in
//            base[keyPath: keyPath] = value
//        }
//    }
//
//    init(_ keyPath: WritableKeyPath<Base, Value?>) {
//        self.init { base in
//            base[keyPath: keyPath]
//        } set: { base, value in
//            base[keyPath: keyPath] = value
//        }
//    }
//
//    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> MutatingRef<Base, T> {
//        MutatingRef<Base, T> { base in
//            get(base)?[keyPath: keyPath]
//        } set: { base, t in
//            guard var value = get(base) else { return }
//            value[keyPath: keyPath] = t
//            set(&base, value)
//        }
//    }
//
//    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T?>) -> MutatingRef<Base, T> {
//        MutatingRef<Base, T> { base in
//            get(base)?[keyPath: keyPath]
//        } set: { base, t in
//            guard var value = get(base) else { return }
//            value[keyPath: keyPath] = t
//            set(&base, value)
//        }
//    }
// }
//
// extension MutatingRef where Value: MutableCollection {
//
//    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value.Element, T>) -> MutatingRef<Base, [T]> {
//        MutatingRef<Base, [T]> { base in
//            get(base)?.map {
//                $0[keyPath: keyPath]
//            }
//        } set: { base, t in
//            guard var value = get(base) else { return }
//            zip(value.indices, t.indices).forEach {
//                value[$0.0][keyPath: keyPath] = t[$0.1]
//            }
//            set(&base, value)
//        }
//    }
// }
//
// extension MutatingRef where Value: MutableDictionary {
//
//    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value.Value, T?>) -> MutatingRef<Base, [Value.Key: T]> {
//    }
//
//    subscript<T>(dynamicMember keyPath: WritableKeyPath<Value.Value, T>) -> MutatingRef<Base, [Value.Key: T]> {
//        MutatingRef<Base, [Value.Key: T]> { base in
//            [:]
////            get(base)?.mapValues {
////                $0[keyPath: keyPath]
////            }
//        } set: { base, t in
////            guard var value = get(base) else { return }
////            zip(value.indices, t.indices).forEach {
////                value[$0.0][keyPath: keyPath] = t[$0.1]
////            }
////            set(&base, value)
//        }
//    }
// }
//
// extension MutatingRef where Value: MutableCollection {
// }
//
// extension KeyPath {
//
//    func callAsFunction<A, T, C>(
//        _ keys: KeyPath<A, some Collection<T>>,
//        _ value: (T) -> WritableKeyPath<A, C>
//    ) where A? == Value {
//
//    }
// }
