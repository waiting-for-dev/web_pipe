module WebPipe
  module Pipe
    # Simple data structure to represent a rack middleware with its
    # initialization options.
    class RackMiddleware
      # @!attribute [r] middleware
      #   @return [Object] Rack middleware
      attr_reader :middleware

      # @!attribute [r] options
      #   @return [Array] Options to initialize `#middleware`
      attr_reader :options

      def initialize(middleware, options)
        @middleware = middleware
        @options = options
      end
    end
  end
end