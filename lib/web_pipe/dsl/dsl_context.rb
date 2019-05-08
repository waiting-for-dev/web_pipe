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
    # @api private
    class DSLContext
      # @!attribute middlewares
      # @return [Array<Rack::Middleware>]

      # @!attribute plugs
      # @return [Array<Plug>]


      include Dry::Initializer.define -> do
        param :middlewares,
              type: Types.Array(Rack::Middleware::Instance)

        param :plugs,
              type: Types.Array(Plug::Instance)
      end

      # Creates and add a rack middleware to the stack.
      #
      # @param middleware
      # [WebPipe::Rack::Middleware::MiddlewareClass[]] Rack middleware
      # @param middleware [WebPipe::Rack::Options[]] Options to
      # initialize
      #
      # @return [Array<Rack::Middleware>]
      def use(middleware, *options)
        middlewares << Rack::Middleware.new(middleware, options)
      end

      # Creates and adds a plug to the stack.
      #
      # @param name [Plug::Name[]]
      # @param with [Plug::Spec[]]
      #
      # @return [Array<Plug>]
      def plug(name, with: nil)
        plugs << Plug.new(name, with)
      end
    end
  end
end