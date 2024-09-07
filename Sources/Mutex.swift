//
//  Mutex.swift
//  AllocatedLock
//
//  Created by Simon Whitty on 07/09/2024.
//  Copyright 2024 Simon Whitty
//
//  Distributed under the permissive MIT license
//  Get the latest version from here:
//
//  https://github.com/swhitty/AllocatedLock
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

// Backports the Swift 6 type Mutex<Value> to all Darwin platforms
// @available(SwiftStdlib 6.0, deprecated, message: "Use Synchronization.Mutex included with Swift 6")
public struct Mutex<Value>: @unchecked Sendable {
    let lock: AllocatedLock<Value> // Compatible with OSAllocatedUnfairLock iOS 16+
}

#if compiler(>=6)
public extension Mutex {
    init(_ initialValue: consuming sending Value) {
        self.lock = AllocatedLock(uncheckedState: initialValue)
    }

    borrowing func withLock<Result, E: Error>(
        _ body: (inout sending Value) throws(E) -> sending Result
    ) throws(E) -> sending Result {
        do {
            return try lock.withLockUnchecked { value in
                nonisolated(unsafe) var copy = value
                defer { value = copy }
                return try Transferring(body(&copy))
            }.value
        } catch let error as E {
            throw error
        } catch {
            preconditionFailure("cannot occur")
        }
    }

    borrowing func withLockIfAvailable<Result, E>(
        _ body: (inout sending Value) throws(E) -> sending Result
    ) throws(E) -> sending Result? where E: Error {
        do {
            return try lock.withLockIfAvailableUnchecked { value in
                nonisolated(unsafe) var copy = value
                defer { value = copy }
                return try Transferring(body(&copy))
            }?.value
        } catch let error as E {
            throw error
        } catch {
            preconditionFailure("cannot occur")
        }
    }
}
#else
public extension Mutex {
    init(_ initialValue: consuming Value) {
        self.lock = AllocatedLock(uncheckedState: initialValue)
    }

    borrowing func withLock<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result {
        try lock.withLockUnchecked {
            return try body(&$0)
        }
    }

    borrowing func withLockIfAvailable<Result>(
        _ body: (inout Value) throws -> Result
    ) rethrows -> Result? {
        try lock.withLockIfAvailableUnchecked {
            return try body(&$0)
        }
    }
}
#endif


#if compiler(>=6)
struct Transferring<T> {
    nonisolated(unsafe) var value: T

    init(_ value: T) {
        self.value = value
    }
}
#endif
