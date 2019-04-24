require 'web_pipe/pipe/plug'
require 'web_pipe/pipe/rack_middleware'

module WebPipe
  module Pipe
    # Defines the DSL for the pipe class.
    #
    # This allows adding rack middlewares and plugs at the class
    # definition level.
    #
    # @private
    class DSL
      # @!attribute middlewares
      #   @return [Array<RackMiddleware>]
      attr_reader :middlewares

      # @!attribute middlewares
      #   @return [Array<Plug>]
      attr_reader :plugs

      def initialize(middlewares, plugs)
        @middlewares = middlewares
        @plugs = plugs
      end

      # Creates and add a rack middleware to the stack.
      #
      # @param middleware [Object] Rack middleware
      # @param middleware [Array] Options to initialize
      #
      # @return [Array<RackMiddleware>]
      def use(middleware, *options)
        middlewares << RackMiddleware.new(middleware, options)
      end

      # Creates and adds a plug to the stack.
      #
      # @param name [String]
      # @param with [#call, nil, String]
      #
      # @return [Array<Plug>]
      def plug(name, with: nil)
        plugs << Plug.new(name, with)
      end
    end
  end
end