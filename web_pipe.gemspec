# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "web_pipe/version"

Gem::Specification.new do |spec|
  spec.name          = "web_pipe"
  spec.version       = WebPipe::VERSION
  spec.authors       = ["Marc Busqué"]
  spec.email         = ["marc@lamarciana.com"]

  spec.summary       = %q{Rack application builder through a pipe of operations on an immutable struct.}
  spec.homepage      = "https://github.com/waiting-for-dev/web_pipe"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["changelog_uri"] = spec.homepage + '/CHANGELOG.md'
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rack", "~> 2.0"
  spec.add_runtime_dependency "dry-monads", "~> 1.2"
  spec.add_runtime_dependency "dry-types", "~> 1.1"
  spec.add_runtime_dependency "dry-struct", "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rack-test", "~> 1.1"
  spec.add_development_dependency "yard", "~> 0.9", ">= 0.9.20"
  spec.add_development_dependency "redcarpet", "~> 3.4"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "dry-view", "~> 0.7"
end
