require 'dry/initializer'
require 'web_pipe/pipe/types'
require 'rack'

module WebPipe
  module Pipe
    # Helper module to build a rack application with middlewares.
    #
    # @private
    class RackApp
      # Type for a rack application.
      #
      # It should be something callable accepting a rack env and
      # returning a rack response.
      App = Types.Contract(:call)

      include Dry::Initializer.define -> do
        # @!attribute [r] rack_middlewares
        #   @return [Array<RackMiddleware>]
        param :rack_middlewares,
              type: Types.Array(RackMiddleware::Instance)

        # @!attribute [r] app
        #    @return [App[]]
        param :app, type: App
      end

      # @!attribute [r] builder
      #   @return [Rack::Builder]
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
        Rack::Builder.new.tap do |b|
          rack_middlewares.each do |middleware|
            b.use(middleware.middleware, *middleware.middleware_options)
          end
          b.run(app)
        end
      end
    end
  end
end