require 'dry/initializer'
require 'web_pipe/types'
require 'web_pipe/rack/middleware'
require 'rack'

module WebPipe
  module Rack
    # Helper to build and call a rack application with middlewares.
    #
    # @api private
    class AppWithMiddlewares
      # Type for a rack application.
      #
      # It should be something callable accepting a rack env and
      # returning a rack response.
      App = Types.Interface(:call)

      # @!attribute [r] rack_middlewares
      # @return [Array<RackMiddleware>]

      # @!attribute [r] app
      # @return [App[]]


      include Dry::Initializer.define -> do
        param :rack_middlewares,
              type: Types.Array(Middleware::Instance)

        param :app, type: App
      end

      # @return [Rack::Builder]
      attr_reader :builder
      
      def initialize(*args)
        super
        @builder = build_rack_app(rack_middlewares, app)
      end

      # Calls rack application.
      #
      # @param env [Hash] Rack env
      #
      # @return [Array] Rack resonse
      def call(env)
        builder.call(env)
      end

      private

      def build_rack_app(rack_middlewares, app)
        ::Rack::Builder.new.tap do |b|
          rack_middlewares.each do |middleware|
            b.use(middleware.middleware, *middleware.middleware_options)
          end
          b.run(app)
        end
      end
    end
  end
end