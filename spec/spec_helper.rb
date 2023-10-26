# frozen_string_literal: true

require 'web_pipe'
require 'pry-byebug'
require 'simplecov'

unless ENV['NO_COVERAGE']
  SimpleCov.start do
    add_filter %r{^/spec/}
    enable_coverage :branch
    enable_coverage_for_eval
  end
end

# https://github.com/dry-rb/dry-configurable/issues/70
WebPipe.load_extensions(
  *WebPipe.instance_variable_get(:@__available_extensions__).keys
)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
