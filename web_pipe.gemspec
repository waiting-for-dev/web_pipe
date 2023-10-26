# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'web_pipe/version'

Gem::Specification.new do |spec|
  spec.name          = 'web_pipe'
  spec.version       = WebPipe::VERSION
  spec.authors       = ['Marc Busqué']
  spec.email         = ['marc@lamarciana.com']
  spec.homepage      = 'https://github.com/waiting-for-dev/web_pipe'
  spec.summary       = 'Rack application builder through a pipe of operations on an immutable struct.'
  spec.licenses      = ['MIT']

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/waiting-for-dev/web_pipe/issues',
    'changelog_uri' => 'https://github.com/waiting-for-dev/web_pipe/blob/main/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/waiting-for-dev/web_pipe/blob/main/README.md',
    'funding_uri' => 'https://github.com/sponsors/waiting-for-dev',
    'label' => 'web_pipe',
    'source_code_uri' => 'https://github.com/waiting-for-dev/web_pipe',
    'rubygems_mfa_required' => 'true'
  }

  spec.required_ruby_version = '>= 3.0'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dry-monads', '~> 1.3'
  spec.add_runtime_dependency 'dry-struct', '~> 1.0'
  spec.add_runtime_dependency 'dry-types', '~> 1.1'
  spec.add_runtime_dependency 'rack', '~> 2.0'
end
