//
//  AllocatedLock.swift
//  swift-mutex
//
//  Created by Simon Whitty on 10/04/2023.
//  Copyright 2023 Simon Whitty
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/swhitty/swift-mutex
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

// Backports the Swift interface around OSAllocatedUnfairLock available in recent Darwin platforms
@available(*, deprecated, message: "Unused by Mutex and will be removed in future versions.")
public struct AllocatedLock<State>: @unchecked Sendable {

    @usableFromInline
    let storage: Storage

    public init(uncheckedState initialState: State) {
        self.storage = Storage(initialState: initialState)
    }

    public init(initialState: State) where State: Sendable {
        self.storage = Storage(initialState: initialState)
    }

    @inlinable
    public func withLock<R>(_ body: @Sendable (inout State) throws -> R) rethrows -> R where R: Sendable {
        storage.lock()
        defer { storage.unlock() }
        return try body(&storage.state)
    }

    @inlinable
    public func withLockIfAvailable<R>(_ body: @Sendable (inout State) throws -> R) rethrows -> R? where R: Sendable {
        guard storage.tryLock() else { return nil }
        defer { storage.unlock() }
        return try body(&storage.state)
    }

    @inlinable
    public func withLockIfAvailableUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R? {
        guard storage.tryLock() else { return nil }
        defer { storage.unlock() }
        return try body(&storage.state)
    }

    @inlinable
    public func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
        storage.lock()
        defer { storage.unlock() }
        return try body(&storage.state)
    }

}

public extension AllocatedLock where State == Void {

    init() {
        self.storage = Storage(initialState: ())
    }

    @inlinable @available(*, noasync)
    func lock() {
        storage.lock()
    }

    @inlinable @available(*, noasync)
    func lockIfAvailable() -> Bool {
        storage.tryLock()
    }

    @inlinable @available(*, noasync)
    func unlock() {
        storage.unlock()
    }

    @inlinable
    func withLock<R>(_ body: @Sendable () throws -> R) rethrows -> R where R: Sendable {
        storage.lock()
        defer { storage.unlock() }
        return try body()
    }

    @inlinable
    func withLockIfAvailable<R>(_ body: @Sendable () throws -> R) rethrows -> R? where R: Sendable {
        guard storage.tryLock() else { return nil }
        defer { storage.unlock() }
        return try body()
    }

    @inlinable
    func withLockIfAvailableUnchecked<R>(_ body: () throws -> R) rethrows -> R? {
        guard storage.tryLock() else { return nil }
        defer { storage.unlock() }
        return try body()
    }

    @inlinable
    func withLockUnchecked<R>(_ body: () throws -> R) rethrows -> R {
        storage.lock()
        defer { storage.unlock() }
        return try body()
    }
}

#if canImport(Darwin)

import struct os.os_unfair_lock_t
import struct os.os_unfair_lock
import func os.os_unfair_lock_lock
import func os.os_unfair_lock_unlock
import func os.os_unfair_lock_trylock

extension AllocatedLock {
    @usableFromInline
    final class Storage {
        private let _lock: os_unfair_lock_t

        @usableFromInline
        var state: State

        init(initialState: State) {
            self._lock = .allocate(capacity: 1)
            self._lock.initialize(to: os_unfair_lock())
            self.state = initialState
        }

        @usableFromInline
        func lock() {
            os_unfair_lock_lock(_lock)
        }

        @usableFromInline
        func unlock() {
            os_unfair_lock_unlock(_lock)
        }

        @usableFromInline
        func tryLock() -> Bool {
            os_unfair_lock_trylock(_lock)
        }

        deinit {
            self._lock.deinitialize(count: 1)
            self._lock.deallocate()
        }
    }
}

#elseif canImport(Glibc) || canImport(Musl) || canImport(Bionic)

#if canImport(Musl)
import Musl
#elseif canImport(Glibc)
import Glibc
#elseif canImport(Bionic)
import Bionic
#endif

extension AllocatedLock {
    @usableFromInline
    final class Storage {
        private let _lock: UnsafeMutablePointer<pthread_mutex_t>

        @usableFromInline
        var state: State

        init(initialState: State) {
            var attr = pthread_mutexattr_t()
            pthread_mutexattr_init(&attr)
            self._lock = .allocate(capacity: 1)
            let err = pthread_mutex_init(self._lock, &attr)
            precondition(err == 0, "pthread_mutex_init error: \(err)")
            self.state = initialState
        }

        @usableFromInline
        func lock() {
            let err = pthread_mutex_lock(_lock)
            precondition(err == 0, "pthread_mutex_lock error: \(err)")
        }

        @usableFromInline
        func unlock() {
            let err = pthread_mutex_unlock(_lock)
            precondition(err == 0, "pthread_mutex_unlock error: \(err)")
        }

        @usableFromInline
        func tryLock() -> Bool {
            pthread_mutex_trylock(_lock) == 0
        }

        deinit {
            let err = pthread_mutex_destroy(self._lock)
            precondition(err == 0, "pthread_mutex_destroy error: \(err)")
            self._lock.deallocate()
        }
    }
}

#elseif canImport(WinSDK)

import ucrt
import WinSDK

extension AllocatedLock {
    @usableFromInline
    final class Storage {
        private let _lock: UnsafeMutablePointer<SRWLOCK>

        @usableFromInline
        var state: State

        init(initialState: State) {
            self._lock = .allocate(capacity: 1)
            InitializeSRWLock(self._lock)
            self.state = initialState
        }

        @usableFromInline
        func lock() {
            AcquireSRWLockExclusive(_lock)
        }

        @usableFromInline
        func unlock() {
            ReleaseSRWLockExclusive(_lock)
        }

        @usableFromInline
        func tryLock() -> Bool {
            TryAcquireSRWLockExclusive(_lock) != 0
        }
    }
}

#endif
