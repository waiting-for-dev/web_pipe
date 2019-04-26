require 'dry/initializer'
require 'web_pipe/pipe/types'

module WebPipe
  module Pipe
    # Simple data structure to represent a rack middleware with its
    # initialization options.
    class RackMiddleware
      include Dry::Initializer.define -> do
        # @!attribute [r] middleware
        #   @return [Object] Rack middleware
        param :middleware, type: Types::Strict::Any

        # @!attribute [r] options
        #   @return [Types::RackMiddleware] Options to initialize the
        #   rack middleware
        param :middleware_options, type: Types::Strict::Array
      end
    end
  end
end