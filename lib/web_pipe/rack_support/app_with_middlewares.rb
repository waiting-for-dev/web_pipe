# frozen_string_literal: true

require "rack"

module WebPipe
  module RackSupport
    # @api private
    class AppWithMiddlewares
      attr_reader :rack_middlewares, :app, :builder

      def initialize(rack_middlewares, app)
        @rack_middlewares = rack_middlewares
        @app = app
        @builder = build_rack_app(rack_middlewares, app)
      end

      def call(env)
        builder.(env)
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
