# frozen_string_literal: true

require 'web_pipe/dsl/builder'

# See [the
# README](https://github.com/waiting-for-dev/web_pipe/blob/master/README.md)
# for a general overview of this library.
module WebPipe
  extend Dry::Core::Extensions

  # Including just delegates to an instance of `Builder`, so
  # `Builder#included` is finally called.
  def self.included(klass)
    klass.include(call)
  end

  def self.call(**opts)
    DSL::Builder.new(**opts)
  end

  register_extension :cookies do
    require 'web_pipe/extensions/cookies/cookies'
  end

  register_extension :dry_schema do
    require 'web_pipe/extensions/dry_schema/dry_schema'
    require 'web_pipe/extensions/dry_schema/plugs/sanitize_params'
  end

  register_extension :hanami_view do
    require 'web_pipe/extensions/hanami_view/hanami_view'
  end

  register_extension :container do
    require 'web_pipe/extensions/container/container'
  end

  register_extension :flash do
    require 'web_pipe/extensions/flash/flash'
  end

  register_extension :router_params do
    require 'web_pipe/extensions/router_params/router_params'
  end

  register_extension :redirect do
    require 'web_pipe/extensions/redirect/redirect'
  end

  register_extension :params do
    require 'web_pipe/extensions/params/params'
  end

  register_extension :rails do
    require 'web_pipe/extensions/rails/rails'
  end

  register_extension :session do
    require 'web_pipe/extensions/session/session'
  end

  register_extension :url do
    require 'web_pipe/extensions/url/url'
  end

  register_extension :not_found do
    require 'web_pipe/extensions/not_found/not_found'
  end
end
