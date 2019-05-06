require 'dry/initializer'
require 'web_pipe/types'
require 'web_pipe/plug'
require 'web_pipe/rack/middleware'

module WebPipe
  module DSL
    # Defines the DSL for the pipe class and keeps it state.
    #
    # This allows adding rack middlewares and plugs at the class
    # definition level.
    #
    # @private
    class DSLContext
      include Dry::Initializer.define -> do
        # @!attribute middlewares
        #   @return [Array<Rack::Middleware>]
        param :middlewares,
              type: Types.Array(Rack::Middleware::Instance)

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
      # @return [Array<Rack::Middleware>]
      def use(middleware, *options)
        middlewares << Rack::Middleware.new(middleware, options)
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