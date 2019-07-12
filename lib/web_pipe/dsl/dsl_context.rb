require 'dry/initializer'
require 'web_pipe/types'
require 'web_pipe/plug'
require 'web_pipe/rack/middleware'
require 'web_pipe/rack/middleware_specification'

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
              type: Types.Array(Rack::Middleware)

        param :plugs,
              type: Types.Array(Plug::Instance)
      end

      # Creates and add rack middlewares to the stack.
      #
      # The spec can be given in two forms:
      #
      # - As one or two arguments, first one being a
      # {::Rack::Middleware} class and second one optionally its
      # initialization options.
      # - As a {WebPipe} class, in which case all its rack middlewares
      # will be added to the stack in order.
      #
      # @param spec [Rack::MiddlewareSpecification::Spec[]]
      #
      # @return [Array<Rack::Middleware>]
      def use(*spec)
        middlewares.push(*Rack::MiddlewareSpecification.call(spec))
      end

      # Creates and adds a plug to the stack.
      #
      # The spec can be given as a {Plug::Spec} or as a block, which
      # is captured into a {Proc} (one of the options for a
      # {Plug::Spec}.
      #
      # @param name [Plug::Name[]]
      # @param spec [Plug::Spec[]]
      # @param block_spec [Proc]
      #
      # @return [Array<Plug>]
      def plug(name, spec = nil, &block_spec)
        plugs << Plug.new(name, spec || block_spec)
      end
    end
  end
end