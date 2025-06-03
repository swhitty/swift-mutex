[![Build](https://github.com/swhitty/swift-mutex/actions/workflows/build.yml/badge.svg)](https://github.com/swhitty/swift-mutex/actions/workflows/build.yml)
[![Codecov](https://codecov.io/gh/swhitty/swift-mutex/graphs/badge.svg)](https://codecov.io/gh/swhitty/swift-mutex)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswhitty%2Fswift-mutex%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/swhitty/swift-mutex)
[![Swift 6.0](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswhitty%2Fswift-mutex%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/swhitty/swift-mutex)

# Introduction

**swift-mutex** is a cross platform lock backporting the Swift 6 [`Mutex`](https://developer.apple.com/documentation/synchronization/mutex) API to Swift 5.9 and all Darwin platforms.

Mutex is built upon [`os_unfair_lock_t`](https://developer.apple.com/documentation/os/os_unfair_lock_t) on Darwin platforms, [`pthread_mutex_t`](https://man.freebsd.org/cgi/man.cgi?pthread_mutex_lock(3)) on Linux and [`SRWLOCK`](https://learn.microsoft.com/en-us/windows/win32/sync/slim-reader-writer--srw--locks) on Windows.

# Installation

The package can be installed by using Swift Package Manager.

 **Note:** Mutex requires Swift 5.9 on Xcode 15+. It runs on iOS 13+, tvOS 13+, macOS 10.15+, Linux and Windows.
To install using Swift Package Manager, add this to the `dependencies:` section in your Package.swift file:

```swift
.package(url: "https://github.com/swhitty/swift-mutex.git", .upToNextMajor(from: "0.0.5"))
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

Or mutate the state:
```swift
let val = state.withLock { 
    $0 += 1
    return $0
}
```

# Gist

A simpler, single file version compatible with macOS 13 / iOS 16 can be found in [this gist](https://gist.github.com/swhitty/571deb25d84c1954a7a01aafa661496e).


# Credits

swift-mutex is primarily the work of [Simon Whitty](https://github.com/swhitty).

([Full list of contributors](https://github.com/swhitty/swift-mutex/graphs/contributors))
