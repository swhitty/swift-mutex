Pod::Spec.new do |spec|
  spec.name = "Mutex"
  spec.version = "0.0.6"
  spec.summary = "A cross platform lock backporting the Swift 6 Mutex API to Swift 5.9 and all Darwin platforms"
  spec.description = <<-DESC
    swift-mutex is a cross platform lock backporting the Swift 6 Mutex API to Swift 5.9 and all Darwin platforms.
    Mutex is built upon os_unfair_lock_t on Darwin platforms, pthread_mutex_t on Linux and SRWLOCK on Windows.
    DESC

  spec.homepage = "https://github.com/swhitty/swift-mutex"
  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.author = { "Simon Whitty" => "simon@whitty.email" }
  spec.source = { :git => "https://github.com/swhitty/swift-mutex.git", :tag => "#{spec.version}" }

  # Supported platforms
  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "10.15"
  spec.tvos.deployment_target = "13.0"
  spec.watchos.deployment_target = "6.0"
  spec.visionos.deployment_target = "1.0"

  # Swift version
  spec.swift_version = "5.9"

  # Source files
  spec.source_files = "Sources/**/*.swift"

  # Test files (optional, for pod try)
  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.swift'
  end
end
