require 'web_pipe/dsl/builder'

# See [the
# README](https://github.com/waiting-for-dev/web_pipe/blob/master/README.md)
# for a general overview of this library.
module WebPipe
  extend Dry::Core::Extensions

  # Including just delegates to an instance of `Builder`, so
  # `Builder#included` is finally called.
  def self.included(klass)
    klass.include(call())
  end

  def self.call(*args)
    DSL::Builder.new(*args)
  end

  register_extension :cookies do
    require 'web_pipe/extensions/cookies/cookies'
  end

  register_extension :dry_schema do
    require 'web_pipe/extensions/dry_schema/dry_schema'
    require 'web_pipe/extensions/dry_schema/plugs/sanitize_params'
    require 'web_pipe/extensions/dry_schema/plugs/param_sanitization_handler'
  end
  
  register_extension :dry_view do
    require 'web_pipe/extensions/dry_view/dry_view'
  end

  register_extension :container do
    require 'web_pipe/extensions/container/container'
  end

  register_extension :flash do
    require 'web_pipe/extensions/flash/flash'
  end

  register_extension :redirect do
    require 'web_pipe/extensions/redirect/redirect'
  end

  register_extension :session do
    require 'web_pipe/extensions/session/session'
  end

  register_extension :url do
    require 'web_pipe/extensions/url/url'
  end
end