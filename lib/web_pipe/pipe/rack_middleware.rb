require 'dry/initializer'
require 'web_pipe/pipe/types'

module WebPipe
  module Pipe
    # Simple data structure to represent a rack middleware with its
    # initialization options.
    class RackMiddleware
      # Type for an instance of self.
      Instance = Types.Instance(self)

      # Type for a rack middleware.
      Middleware = Types.Instance(Class)

      # Type for the options to initialize a rack middleware.
      Options = Types::Strict::Array

      include Dry::Initializer.define -> do
        # @!attribute [r] middleware
        #   @return [Middleware[]] Rack middleware
        param :middleware, type: Middleware

        # @!attribute [r] options
        #   @return [Options[]] Options to initialize the rack
        #   middleware
        param :middleware_options, type: Options
      end
    end
  end
end