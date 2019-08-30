require 'web_pipe/types'
require 'web_pipe/conn'
require 'web_pipe/app'
require 'web_pipe/plug'
require 'web_pipe/rack_support/app_with_middlewares'
require 'web_pipe/rack_support/middleware_specification'
require 'web_pipe/conn_support/composition'

module WebPipe
  module DSL
    # Instance methods for the pipe.
    #
    # It is from here that you get the rack application you can route
    # to. The initialization phase gives you the chance to inject any
    # of the plugs or middlewares, while the instance you get has the
    # `#call` method expected by rack.
    #
    # The pipe state can be accessed through the pipe class, which
    # has been configured through {ClassContext}.
    #
    # @api private
    module InstanceMethods
      # No injections at all.
      EMPTY_INJECTIONS = {
        plugs: Types::EMPTY_HASH,
        middlewares: Types::EMPTY_HASH
      }.freeze

      # Type for how plugs and middlewares should be injected.
      Injections = Types::Strict::Hash.schema(
        plugs: Plug::Injections,
        middlewares: RackSupport::MiddlewareSpecification::Injections
      )

      # @!attribute [r] injections [Injections[]]
      #   Injected plugs and middlewares that allow overriding what
      # has been configured.
      attr_reader :injections

      # @return [RackSupport::AppWithMiddlewares[]]
      attr_reader :rack_app

      # @return [ConnSupport::Composition::Operation[]]
      attr_reader :operations

      # @return [Array<RackSupport::Middlewares>]
      attr_reader :middlewares

      def initialize(injects = EMPTY_INJECTIONS)
        @injections = Injections[injects]
        container = self.class.container
        @middlewares = RackSupport::MiddlewareSpecification.inject_and_resolve(
          self.class.middleware_specifications, injections[:middlewares]
        )
        @operations = Plug.inject_and_resolve(
          self.class.plugs, injections[:plugs], container, self
        )
        app = App.new(operations)
        @rack_app = RackSupport::AppWithMiddlewares.new(middlewares, app)
      end
      
      # Expected interface for rack.
      #
      # @param env [Hash] Rack env
      #
      # @return [Array] Rack response
      def call(env)
        rack_app.call(env)
      end

      # Proc for the composition of all operations.
      #
      # This can be used to plug a {WebPipe} itself as an operation.
      #
      # @example
      #   class HtmlApp
      #     include WebPipe
      #
      #     plug :html
      #
      #     private
      #
      #     def html(conn)
      #       conn.add_response_header('Content-Type', 'text/html')
      #     end
      #   end
      #
      #   class App
      #     include WebPipe
      #
      #     plug :html, &HtmlApp.new
      #     plug :body
      #
      #     private
      #
      #     def body(conn)
      #        conn.set_response_body('Hello, world!')
      #     end
      #   end
      #
      # @see ConnSupport::Composition
      def to_proc
        ConnSupport::Composition.
          new(operations).
          method(:call).
          to_proc
      end
    end
  end
end
