[![Build](https://github.com/swhitty/AllocatedLock/actions/workflows/build.yml/badge.svg)](https://github.com/swhitty/AllocatedLock/actions/workflows/build.yml)
[![Codecov](https://codecov.io/gh/swhitty/AllocatedLock/graphs/badge.svg)](https://codecov.io/gh/swhitty/AllocatedLock)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20|%20Mac%20|%20tvOS%20|%20Linux%20|%20Windows-lightgray.svg)](https://github.com/swhitty/AllocatedLock/blob/main/Package.swift)
[![Swift 5.10](https://img.shields.io/badge/swift-5.7%20–%205.10-red.svg?style=flat)](https://developer.apple.com/swift)
[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Twitter](https://img.shields.io/badge/twitter-@simonwhitty-blue.svg)](http://twitter.com/simonwhitty)

# Introduction

**AllocatedLock** is a lightweight cross platform lock with an API compatible with [`OSAllocatedUnfairLock`](https://developer.apple.com/documentation/os/osallocatedunfairlock).  The lock wraps [`os_unfair_lock_t`](https://developer.apple.com/documentation/os/os_unfair_lock_t) on Darwin platforms, [`pthread_mutex_t`](https://man.freebsd.org/cgi/man.cgi?pthread_mutex_lock(3)) on Linux and [`SRWLOCK`](https://learn.microsoft.com/en-us/windows/win32/sync/slim-reader-writer--srw--locks) on Windows.

# Installation

AllocatedLock can be installed by using Swift Package Manager.

 **Note:** AllocatedLock requires Swift 5.7 on Xcode 14+. It runs on iOS 13+, tvOS 13+, macOS 10.15+, Linux and Windows.
To install using Swift Package Manager, add this to the `dependencies:` section in your Package.swift file:

```swift
.package(url: "https://github.com/swhitty/AllocatedLock.git", .upToNextMajor(from: "0.0.3"))
```

# Usage

Usage is similar with [`OSAllocatedUnfairLock`](https://developer.apple.com/documentation/os/osallocatedunfairlock).

The recommended usage to create a lock that protects some state:
```swift
let state = AllocatedLock<Int>(initialState: 0)
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

AllocatedLock is primarily the work of [Simon Whitty](https://github.com/swhitty).

([Full list of contributors](https://github.com/swhitty/AllocatedLock/graphs/contributors))
