require 'dry/initializer'
require 'web_pipe/types'
require 'web_pipe/conn'
require 'web_pipe/app'
require 'web_pipe/plug'
require 'web_pipe/rack/app_with_middlewares'
require 'web_pipe/conn_support/composition'

module WebPipe
  module DSL
    # Instance methods for the pipe.
    #
    # It is from here that you get the rack application you can route
    # to. The initialization phase gives you the chance to inject any
    # of the plugs, while the instance you get has the `#call` method
    # expected by rack.
    #
    # The pipe state can be accessed through the pipe class, which
    # has been configured through {ClassContext}.
    #
    # @api private
    module InstanceMethods
      # No injections at all.
      EMPTY_INJECTIONS = Types::EMPTY_HASH

      # Type for how plugs should be injected.
      Injections = Types::Strict::Hash.map(Plug::Name, Plug::Spec)

      # @!attribute [r] injections [Injections[]]
      #   Injected plugs that allow overriding what has been configured.


      include Dry::Initializer.define -> do
        param :injections,
              default: proc { EMPTY_INJECTIONS },
              type: Injections
      end

      # @return [Rack::AppWithMiddlewares[]]
      attr_reader :rack_app

      # @return [ConnSupport::Composition::Operation[]]
      attr_reader :operations

      def initialize(*args)
        super
        middlewares = self.class.middlewares
        container = self.class.container
        @operations = Plug.inject_and_resolve(self.class.plugs, injections, container, self)
        app = App.new(operations)
        @rack_app = Rack::AppWithMiddlewares.new(middlewares, app)
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
      #       conn.set_response_header('Content-Type', 'text/html')
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