//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Logging API open source project
//
// Copyright (c) 2018-2019 Apple Inc. and the Swift Logging API project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of Swift Logging API project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2018 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#if canImport(WASILibc)
// No locking on WASILibc
#elseif canImport(Darwin)
import Darwin
#elseif os(Windows)
import WinSDK
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Musl)
import Musl
#else
#error("Unsupported runtime")
#endif


/// A reader/writer threading lock based on `libpthread` instead of `libdispatch`.
///
/// This object provides a lock on top of a single `pthread_rwlock_t`. This kind
/// of lock is safe to use with `libpthread`-based threading models, such as the
/// one used by NIO. On Windows, the lock is based on the substantially similar
/// `SRWLOCK` type.
final class ReadWriteLock {
	#if canImport(WASILibc)
	// WASILibc is single threaded, provides no locks
	#elseif os(Windows)
	fileprivate let rwlock: UnsafeMutablePointer<SRWLOCK> =
		UnsafeMutablePointer.allocate(capacity: 1)
	fileprivate var shared = true
	#else
	fileprivate let rwlock: UnsafeMutablePointer<pthread_rwlock_t> =
		UnsafeMutablePointer.allocate(capacity: 1)
	#endif

	/// Create a new lock.
	public init() {
		#if canImport(WASILibc)
		// WASILibc is single threaded, provides no locks
		#elseif os(Windows)
		InitializeSRWLock(rwlock)
		#else
		let err = pthread_rwlock_init(rwlock, nil)
		precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
		#endif
	}

	deinit {
		#if canImport(WASILibc)
		// WASILibc is single threaded, provides no locks
		#elseif os(Windows)
		// SRWLOCK does not need to be free'd
		self.rwlock.deallocate()
		#else
		let err = pthread_rwlock_destroy(self.rwlock)
		precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
		self.rwlock.deallocate()
		#endif
	}

	/// Acquire a reader lock.
	///
	/// Whenever possible, consider using `withReaderLock` instead of this
	/// method and `unlock`, to simplify lock handling.
	public func lockRead() {
		#if canImport(WASILibc)
		// WASILibc is single threaded, provides no locks
		#elseif os(Windows)
		AcquireSRWLockShared(rwlock)
		shared = true
		#else
		let err = pthread_rwlock_rdlock(rwlock)
		precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
		#endif
	}

	/// Acquire a writer lock.
	///
	/// Whenever possible, consider using `withWriterLock` instead of this
	/// method and `unlock`, to simplify lock handling.
	public func lockWrite() {
		#if canImport(WASILibc)
		// WASILibc is single threaded, provides no locks
		#elseif os(Windows)
		AcquireSRWLockExclusive(rwlock)
		shared = false
		#else
		let err = pthread_rwlock_wrlock(rwlock)
		precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
		#endif
	}

	/// Release the lock.
	///
	/// Whenever possible, consider using `withReaderLock` and `withWriterLock`
	/// instead of this method and `lockRead` and `lockWrite`, to simplify lock
	/// handling.
	public func unlock() {
		#if canImport(WASILibc)
		// WASILibc is single threaded, provides no locks
		#elseif os(Windows)
		if shared {
			ReleaseSRWLockShared(rwlock)
		} else {
			ReleaseSRWLockExclusive(rwlock)
		}
		#else
		let err = pthread_rwlock_unlock(rwlock)
		precondition(err == 0, "\(#function) failed in pthread_rwlock with error \(err)")
		#endif
	}
}

extension ReadWriteLock {
	/// Acquire the reader lock for the duration of the given block.
	///
	/// This convenience method should be preferred to `lockRead` and `unlock`
	/// in most situations, as it ensures that the lock will be released
	/// regardless of how `body` exits.
	///
	/// - Parameter body: The block to execute while holding the reader lock.
	/// - Returns: The value returned by the block.
	@inlinable
	func withReaderLock<T>(_ body: () throws -> T) rethrows -> T {
		lockRead()
		defer {
			self.unlock()
		}
		return try body()
	}

	/// Acquire the writer lock for the duration of the given block.
	///
	/// This convenience method should be preferred to `lockWrite` and `unlock`
	/// in most situations, as it ensures that the lock will be released
	/// regardless of how `body` exits.
	///
	/// - Parameter body: The block to execute while holding the writer lock.
	/// - Returns: The value returned by the block.
	@inlinable
	func withWriterLock<T>(_ body: () throws -> T) rethrows -> T {
		lockWrite()
		defer {
			self.unlock()
		}
		return try body()
	}

	/// specialise Void return (for performance)
	@inlinable
	func withReaderLockVoid(_ body: () throws -> Void) rethrows {
		try withReaderLock(body)
	}

	/// specialise Void return (for performance)
	@inlinable
	func withWriterLockVoid(_ body: () throws -> Void) rethrows {
		try withWriterLock(body)
	}
}

@propertyWrapper
final class Lock<T> {

    private let lock = ReadWriteLock()
    private var value: T

    init(wrappedValue: T) {
        self.value = wrappedValue
    }
    
    convenience init(_ value: T) {
        self.init(wrappedValue: value)
    }

    var wrappedValue: T {
        get { lock.withReaderLock { value } }
        set { lock.withWriterLockVoid { value = newValue } }
    }

    func withReaderLock<U>(_ body: (T) throws -> U) rethrows -> U {
        try lock.withReaderLock { try body(value) }
    }

    func withWriterLock(_ body: (inout T) throws -> Void) rethrows {
        try lock.withWriterLockVoid {
            try body(&value)
        }
    }
}
