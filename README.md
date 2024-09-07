[![Build](https://github.com/swhitty/swift-mutex/actions/workflows/build.yml/badge.svg)](https://github.com/swhitty/swift-mutex/actions/workflows/build.yml)
[![Codecov](https://codecov.io/gh/swhitty/swift-mutex/graphs/badge.svg)](https://codecov.io/gh/swhitty/swift-mutex)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20Mac%20|%20tvOS%20|%20Linux%20|%20Windows-lightgray.svg)](https://github.com/swhitty/swift-mutex/blob/main/Package.swift)
[![Swift 5.10](https://img.shields.io/badge/swift-5.7%20–%205.10-red.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@simonwhitty-blue.svg)](http://twitter.com/simonwhitty)

# Introduction

**swift-mutex** is a cross platform lock backporting the Swift 6 [`Mutex`](https://developer.apple.com/documentation/synchronization/mutex) API to Swift 5.9 and all Darwin platforms.

Mutex is built upon AllocatedLock which is cross platform lock with an API compatible with [`OSAllocatedUnfairLock`](https://developer.apple.com/documentation/os/osallocatedunfairlock).  The lock wraps [`os_unfair_lock_t`](https://developer.apple.com/documentation/os/os_unfair_lock_t) on Darwin platforms, [`pthread_mutex_t`](https://man.freebsd.org/cgi/man.cgi?pthread_mutex_lock(3)) on Linux and [`SRWLOCK`](https://learn.microsoft.com/en-us/windows/win32/sync/slim-reader-writer--srw--locks) on Windows.

# Installation

The package can be installed by using Swift Package Manager.

 **Note:** Mutex requires Swift 5.9 on Xcode 15+. It runs on iOS 13+, tvOS 13+, macOS 10.15+, Linux and Windows.
To install using Swift Package Manager, add this to the `dependencies:` section in your Package.swift file:

```swift
.package(url: "https://github.com/swhitty/swift-mutex.git", .upToNextMajor(from: "0.0.4"))
```

# Usage

Usage is similar to the Swift 6 [`Mutex`](https://developer.apple.com/documentation/synchronization/mutex)

```swift
let state = Mutex<Int>(0)
```

Use `.withLock` to acquire the lock to read the state:
```swift
let val = state.withLock { $0 }
```

Or mutate the state
```swift
let val = state.withLock { $0 += 1 }
```

# Credits

swift-mutex is primarily the work of [Simon Whitty](https://github.com/swhitty).

([Full list of contributors](https://github.com/swhitty/swift-mutex/graphs/contributors))
