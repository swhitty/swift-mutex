//
//  AllocatedLockTests.swift
//  AllocatedLock
//
//  Created by Simon Whitty on 10/04/2023.
//  Copyright 2023 Simon Whitty
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

@testable import Mutex
import XCTest

final class AllocatedLockTests: XCTestCase {

    func testLockState_IsProtected() async {
        let state = AllocatedLock<Int>(initialState: 0)

        let total = await withTaskGroup(of: Void.self) { group in
            for i in 1...1000 {
                group.addTask {
                    state.withLock { $0 += i }
                }
            }
            await group.waitForAll()
            return state.withLock { $0 }
        }

        XCTAssertEqual(total, 500500)
    }

    func testLock_ReturnsValue() async {
        let lock = AllocatedLock()
        let value = lock.withLock { true }
        XCTAssertTrue(value)
    }


    func testLock_Blocks() async {
        let lock = AllocatedLock()
        await MainActor.run {
            lock.unsafeLock()
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 200_000)
            lock.unsafeUnlock()
        }

        let results = await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                try? await Task.sleep(nanoseconds: 10_000)
                return true
            }
            group.addTask {
                lock.unsafeLock()
                lock.unsafeUnlock()
                return false
            }
            let first = await group.next()!
            let second = await group.next()!
            return [first, second]
        }
        XCTAssertEqual(results, [true, false])
    }

    func testTryLock() {
        let lock = AllocatedLock()
        let value = lock.withLock { true }
        XCTAssertTrue(value)
    }

    func testIfAvailable() {
        let lock = AllocatedLock(uncheckedState: 5)
        XCTAssertEqual(
            lock.withLock { _ in "fish" },
            "fish"
        )

        lock.unsafeLock()
        XCTAssertEqual(
            lock.withLockIfAvailable { _ in "fish" },
            String?.none
        )

        lock.unsafeUnlock()
        XCTAssertEqual(
            lock.withLockIfAvailable { _ in "fish" },
            "fish"
        )
    }

    func testIfAvailableUnchecked() {
        let lock = AllocatedLock(uncheckedState: NonSendable("fish"))
        XCTAssertEqual(
            lock.withLockUnchecked { $0 }.name,
            "fish"
        )

        lock.unsafeLock()
        XCTAssertNil(
            lock.withLockIfAvailableUnchecked { $0 }?.name
        )

        lock.unsafeUnlock()
        XCTAssertEqual(
            lock.withLockIfAvailableUnchecked { $0 }?.name,
            "fish"
        )
    }

    func testVoidIfAvailable() {
        let lock = AllocatedLock()
        XCTAssertEqual(
            lock.withLock { "fish" },
            "fish"
        )

        lock.unsafeLock()
        XCTAssertEqual(
            lock.withLockIfAvailable { "fish" },
            String?.none
        )

        lock.unsafeUnlock()
        XCTAssertEqual(
            lock.withLockIfAvailable { "fish" },
            "fish"
        )
    }

    func testVoidIfAvailableUnchecked() {
        let lock = AllocatedLock()
        XCTAssertEqual(
            lock.withLockUnchecked { NonSendable("fish") }.name,
            "fish"
        )

        lock.lock()
        XCTAssertNil(
            lock.withLockIfAvailableUnchecked { NonSendable("fish") }
        )

        lock.unlock()
        XCTAssertEqual(
            lock.withLockIfAvailableUnchecked { NonSendable("chips") }?.name,
            "chips"
        )
    }

    func testVoidLock() {
        let lock = AllocatedLock()
        lock.lock()
        XCTAssertFalse(lock.lockIfAvailable())
        lock.unlock()
        XCTAssertTrue(lock.lockIfAvailable())
        lock.unlock()
    }
}

public final class NonSendable {

    let name: String

    init(_ name: String) {
        self.name = name
    }
}

// sidestep warning: unavailable from asynchronous contexts
extension AllocatedLock {
    func unsafeLock() { storage.lock() }
    func unsafeUnlock() { storage.unlock() }
}
