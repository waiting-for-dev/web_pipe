require 'dry/initializer'
require 'web_pipe/types'

module WebPipe
  module Rack
    # Simple data structure to represent a rack middleware class with
    # its initialization options.
    class Middleware
      # Type for an instance of self.
      Instance = Types.Instance(self)

      # Type for a rack middleware class.
      MiddlewareClass = Types.Instance(Class)

      # Type for the options to initialize a rack middleware.
      Options = Types::Strict::Array

      # @!attribute [r] middleware
      #   @return [MiddlewareClass[]] Rack middleware

      # @!attribute [r] options
      # @return [Options[]]
      # Options to initialize the rack middleware


      include Dry::Initializer.define -> do
        param :middleware, type: MiddlewareClass

        param :middleware_options, type: Options
      end
    end
  end
end