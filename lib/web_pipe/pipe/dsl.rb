require 'dry/initializer'
require 'web_pipe/pipe/types'
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
      include Dry::Initializer.define -> do
        # @!attribute middlewares
        #   @return [Array<RackMiddleware>]
        param :middlewares,
              type: Types.Array(RackMiddleware::Instance)

        # @!attribute middlewares
        #   @return [Array<Plug>]
        param :plugs,
              type: Types.Array(Plug::Instance)
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
      # @param with [Plug::Spec]
      #
      # @return [Array<Plug>]
      def plug(name, with: nil)
        plugs << Plug.new(name, with)
      end
    end
  end
end