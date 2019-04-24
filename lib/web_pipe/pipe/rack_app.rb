require 'rack'

module WebPipe
  module Pipe
    # Helper module to build a rack application with middlewares.
    #
    # @private
    class RackApp
      # @!attribute [r] builder
      #   @return [Rack::Builder]
      attr_reader :builder
      
      # @param rack_middlewares [Array<RackMiddleware>]
      # @param app [#call]
      def initialize(rack_middlewares, app)
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
            b.use(middleware.middleware, *middleware.options)
          end
          b.run(app)
        end
      end
    end
  end
end