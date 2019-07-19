require 'web_pipe'
require 'web_pipe/types'
require 'web_pipe/plug'
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
      # @!attribute middleware_specifications
      # @return [Array<Rack::MiddlewareSpecifications>]
      attr_reader :middleware_specifications

      # @!attribute plugs
      # @return [Array<Plug>]
      attr_reader :plugs

      def initialize(middleware_specifications, plugs)
        @middleware_specifications = Types.Array(
          Rack::MiddlewareSpecification
        )[middleware_specifications]
        @plugs = Types.Array(Plug::Instance)[plugs]
      end

      # Creates and add rack middleware specifications to the stack.
      #
      # The spec can be given in two forms:
      #
      # - As one or two arguments, first one being a
      # rack middleware class and second one optionally its
      # initialization options.
      # - As a {WebPipe} class instance, in which case all its rack
      # middlewares will be considered.
      #
      # @param name [Rack::MiddlewareSpecification::Name[]]
      # @param spec [Rack::MiddlewareSpecification::Spec[]]
      #
      # @return [Array<Rack::Middleware>]
      def use(name, *spec)
        middleware_specifications << Rack::MiddlewareSpecification.new(name, spec)
      end

      # Creates and adds a plug to the stack.
      #
      # The spec can be given as a {Plug::Spec}, as a block (which
      # is captured into a {Proc}, one of the options for a
      # {Plug::Spec} or as a {WebPipe} (in which case all its plugs
      # will be composed).
      #
      # @param name [Plug::Name[]]
      # @param spec [Plug::Spec[], WebPipe]
      # @param block_spec [Proc]
      #
      # @return [Array<Plug>]
      def plug(name, spec = nil, &block_spec)
        plug_spec = if spec.is_a?(WebPipe)
                 spec.to_proc
               elsif spec
                 spec
               else
                 block_spec
               end

        plugs << Plug.new(name, plug_spec)
      end

      # Adds middlewares and plugs from a WebPipe to respective
      # stacks.
      #
      # @param name [Plug::Name[], Middleware::Name[]]
      # @param spec [WebPipe]
      def compose(name, spec)
        use(name, spec)
        plug(name, spec)
      end
    end
  end
end