require 'rack'

module WebPipe
  module Pipe
    class RackApp
      attr_reader :builder
      
      def initialize(middlewares, app)
        @builder = build_rack_app(middlewares, app)
      end

      def call(env)
        builder.call(env)
      end

      private

      def build_rack_app(middlewares, app)
        Rack::Builder.new.tap do |b|
          middlewares.each do |middleware, args|
            b.use(middleware, *args)
          end
          b.run(app)
        end
      end
    end
  end
end