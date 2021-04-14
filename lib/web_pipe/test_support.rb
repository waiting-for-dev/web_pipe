# frozen_string_literal: true

require 'web_pipe/conn_support/builder'
require 'rack/mock'

module WebPipe
  # Test helper methods.
  #
  # This module is meant to be included in a test file to provide helper
  # methods.
  module TestSupport
    # Builds a {WebPipe::Conn}
    #
    # @param uri [String] URI that will be used to populate the request
    # attributes
    # @param attributes [Hash<Symbol, Any>] Manually set attributes for the
    # struct. It overrides what is taken from the `uri` parameter
    # @param env_opts [Hash] Options to be added to the `env` from which the
    # connection struct is created. See {Rack::MockRequest.env_for}.
    # @return [Conn]
    def build_conn(uri = '', attributes: {}, env_opts: {})
      env = Rack::MockRequest.env_for(uri, env_opts)
      ConnSupport::Builder
        .call(env)
        .new(attributes)
    end
  end
end
