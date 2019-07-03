require "bundler/setup"
require "web_pipe"
require 'pry-byebug'
require "web_pipe/conn"

# https://github.com/dry-rb/dry-configurable/issues/70
WebPipe.load_extensions(
  *WebPipe.instance_variable_get(:@__available_extensions__).keys
)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end